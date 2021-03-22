#!/bin/env node

/**
 * Download a video+audio segmented stream from Vimeo.
 *
 * Usage:
 *     downvimeo.js \
 *         'https://27skyfiregce-vimeo.akamaized.net/exp=1570190656~acl=%2F201273826%2F%2A~hmac=ed4e4e566020512abd17c9a01227e116ca32740b4d344bb1cb8e36c29e2d9589/201273826/sep/video/948847971,948847968,948847963/master.json?base64_init=1' \
 *         'Cum să Faci Față Principalelor 4 Probleme ale Părintelui Modern'
 *
 * ffmpeg is required to join video and audio streams
 *
 * @author  Dumitru Uzun (DUzun.Me)
 * @version  1.0.2
 */

/*jshint
    node: true,
    esversion: 7
*/

const fs    = require('fs');
const https = require('https');
const http  = require('http');
const url   = require('url');
const path  = require('path');
const zlib  = require('zlib');
const { exec } = require('child_process');

const { argv } = process;

let link = argv[2];
let dest = argv[3];

const _url_reg_ = /^https?\:\/\//;

// Swap $1 with $2 if $2 is an URL and $1 is not
if(dest && _url_reg_.test(dest) && !_url_reg_.test(link)) {
    let t = dest;
    dest = link;
    link = t;
}

const state = {};

request(link, state)
.then(({data, res, state}) => {
    let json = JSON.parse(data);
    let { clip_id, base_url, video, audio } = json;
    base_url = url.resolve(link, base_url);
    video.sort((a,b) => b.width - a.width);
    video = video[0];
    let _audio = audio.find((a) => a.id == video.id);
    if(!_audio) {
        audio.sort((a,b) => b.bitrate - a.bitrate);
        _audio = audio[0];
    }
    audio = _audio;

    let video_base = url.resolve(base_url, video.base_url);
    let audio_base = url.resolve(base_url, audio.base_url);
    let type = video.mime_type.split('/').pop();

    if(!dest) {
        dest = clip_id + '.' + type;
    }
    else {
        let ext = path.extname(dest);
        if(!ext || ext == '.' || ext.length > 3) {
            dest += '.' + type;
        }
    }


    let videoSegments = video.segments.map((s) => url.resolve(video_base, s.url));
    let audioSegments = audio.segments.map((s) => url.resolve(audio_base, s.url));
    let segmentsCount = videoSegments.length;
    let index = 0;

    let destVideo = clip_id + '.video.' + type;
    let destAudio = clip_id + '.audio.' + type;

    // console.log({ dest, base_url, video_base, audio_base });
    let destStream = fs.createWriteStream(destVideo);
    let destAudStream = fs.createWriteStream(destAudio);
    let totalSize = 0;

    return (function downSeg(index){
        return Promise.all([
            request(videoSegments[index], state),
            request(audioSegments[index], state),
        ])
        .then(([vid, aud]) => {
            if(index == 0) {
                if(video.init_segment) {
                    let initSeg = Buffer.from(video.init_segment, 'base64');
                    destStream.write(initSeg);
                    totalSize += initSeg.length;
                }
            }
            let data = vid.data;
            totalSize += data.length;
            destStream.write(data);

            if(index == 0) {
                if(audio.init_segment) {
                    let initSeg = Buffer.from(audio.init_segment, 'base64');
                    destAudStream.write(initSeg);
                    totalSize += initSeg.length;
                }
            }
            data = aud.data;
            totalSize += data.length;
            destAudStream.write(data);

            console.log(index, '/', segmentsCount, totalSize);

            if(++index < segmentsCount) {
                return downSeg(index);
            }
            destStream.end();
            destAudStream.end();
            return totalSize;
        });
    }(0))
    .then((size) => {
        console.log('done downloading', size);
        console.log(`ffmpeg: video + audio > "${dest}"`);

        return new Promise((resolve, reject) =>
            exec(`ffmpeg -y -i '${destVideo}' -i '${destAudio}' -c copy -strict experimental '${dest}'`, (err, stdout, stderr) => {
                if(err) return reject(err);
                fs.unlink(destVideo, (err) => {
                    fs.unlink(destAudio, (err) => {
                        resolve(size);
                    });
                });
            })
        );
    });
})
.then(() => {
    console.log('All done');
});

/**
 *  Make an http(s) request.
 *
 *  Defaults to GET if no .data, and POST for .data.
 *  Can have .cookie.
 *  The .data is automatically .write()en.
 *  If .filename present, downloads contents to it.
 *  Additionally .filesize can be checked before writing to .filename.
 *
 *  @param (object|string)opt - url or options object
 *  @param (function)cb(err, data, resp, state)
 *  @param (object)state - to store cookie so far
 *
 *  @return (Request) .end()ed
 */
function request(opt, state, cb) {
    // Swap cb with state, if state is the cb:
    if (typeof cb != 'function') {
        let t = cb;
        cb = typeof state == 'function' ? state : undefined;
        state = t;
    }
    if (typeof opt == 'string') {
        opt = { url: opt };
    }
    var _url = opt.url && new URL(opt.url);      
    var protocol = opt.protocol || _url && _url.protocol || ((opt.port||_url&&_url.port) == 443 ? 'https:' : 'http:');
    if (!('port' in opt) && !_url) {
        opt.port = protocol == 'https:' ? 443 : 80;
    }
    
    // Default headers
    var _headers = {
        // "User-Agent": "Mozilla/5.0 (Windows NT 6.4; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3880.4 Safari/537.36",
        "User-Agent": "Mozilla/5.0 (Windows NT 6.4)",
        "Accept-Encoding": "gzip, deflate, br",
        "Accept-Language": "en-US,en;q=0.8",
        "Accept": "*/*",
        'Origin': _url && _url.oriring || (protocol + '//' + (opt.hostname || opt.host)),
    };
    _headers['Referer'] = _headers['Origin'] + '/';

    var data = opt.data;
    if ('data' in opt) {
        if (!opt.method) opt.method = 'POST';
        // Default method for data requests is GET
        _headers['Content-Length'] = data && data.length || 0;
    }

    // Default method is GET
    if (!opt.method) opt.method = 'GET';

    var cookie = state && state.cookie;
    // opt.cookie can overwrite state.cookie;
    if ('cookie' in opt) {
        cookie = opt.cookie;
    }
    if (!isEmptyObject(cookie)) {
        _headers['Cookie'] = cookies2header(cookie);
    }

    // Headers in opt.headers are more important then the dynamic ones
    if (opt.headers) {
        Object.keys(opt.headers).forEach(function (n) {
            _headers[n] = opt.headers[n];
        });
    }
    opt.headers = _headers;

    // File download
    let { 
        filename, 
        filesize, // expected filesize
    } = opt;

    // Remove special options:
    delete opt.url;
    delete opt.data;
    delete opt.cookie;
    delete opt.filename;
    delete opt.filesize;

    var resolve, reject, prom;
    if(!cb) {
        prom = new Promise((_res, _rej) => {
            resolve = _res;
            reject = _rej;
        });
        cb = (err, data, res, state) => {
            if(err) {
                if(data) err.data = data;
                if(res) err.res = res;
                if(state) err.state = state;
                return reject(err);
            }
            resolve({data, req, res, state});
        };
    }

    var hlib = protocol == 'https:' ? https : http;
    var req = hlib.request(_url, opt, function (resp) {
        // log('STATUS: ' + resp.statusCode);
        if (state) {
            state.cookie = getCookies(resp, state.cookie);
        }
        // File download request:
        if (filename) {
            if (resp.statusCode == 200) {
                let str = inflateResponse(resp);
                s2p(str)
                .then((data) => {
                    // Check filesize
                    if (filesize != undefined && filesize != data.length) {
                        let err = new Error(`Data doesn't have the expected size of "${filesize}"`);
                        err.expectedSize = filesize;
                        err.actualSize = data.length;
                        throw err;
                    }
                    fs.writeFile(filename, data, (err) => {
                        cb(err, data, resp, state);
                    });
                })
                .catch((err) => cb(err, data, resp, state));
            }
            else {
                let err = new Error(`Can't download file: ${resp.statusMessage}`);
                // err.code = 'http';
                err.status = resp.statusCode;
                err.statusMessage = resp.statusMessage;
                cb(err, null, resp, state);
            }
        }
        // Data request:
        else {
            let str = inflateResponse(resp);
            s2p(str)
            .then((data) => {
                cb(null, data, resp, state);                
            }, (err) => {
                cb(err, str, resp, state);                
            })
            ;            
        }
    });
    req.on('error', function (err) {
        cb(err, null, null, state);
    });
    if (data) req.write(data);
    req.end();

    if(prom) {
        prom.req = req;
    }
    else {
        prom = req;
    }
    return prom;
}

function inflateResponse(resp) {
    let encoding = resp.headers['content-encoding'];
    if(encoding) {        
        switch(true) {
            case encoding.indexOf('br') >= 0: 
                return resp.pipe(zlib.createBrotliDecompress());                
            case encoding.indexOf('gzip') >= 0: 
                return resp.pipe(zlib.createGunzip());                
            case encoding.indexOf('deflate') >= 0: 
                return resp.pipe(zlib.createInflate());                          
        }
    }

    return resp;
}

/**
 * Stream to Promise - add .then and .catch to the stream
 * 
 * @param  {Stream} str a Readable Stream
 * @return {Stream} str, whcih is a hybrid Stream + Promise
 */
function s2p(str) {
    if(typeof str.then == 'function') return str;

    let prom;

    const then = (resolve, reject) => {
        if(!prom) {
            prom = new Promise((res, rej) => {                
                let body = [];
                str.on('data', (chunk) => { body.push(chunk); });
                str.on('end', () => { res(body = Buffer.concat(body)); });
                str.on('error', rej);
            });
        }
        return prom.then(resolve, reject);
    };

    str.then = then;
    str.catch = then.bind(undefined, undefined);

    return str;
}

function getCookies(resp, list) {
    if (!list) list = {};
    let cooks = resp.headers['set-cookie'];
    if (cooks) {
        cooks.forEach(function (c) {
            let t = c.split(';');
            let n = t[0].split('=');
            list[n[0]] = n[1];
        });
    }
    return list;
}

function cookies2header(list) {
    if (list) {
        return Object.keys(list)
            .map((n) => n + '=' + list[n])
            .join('; ')
            ;
    }
}

function isEmptyObject(obj) {
    if (obj) for (let i in obj) if (Object.prototype.hasOwnProperty.call(obj, i)) return false;
    return true;
}
