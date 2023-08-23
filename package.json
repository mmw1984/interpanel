const { io } = require('socket.io-client');
const { v4 } = require('uuid');
const md5 = require('md5');
const http = require('http');
const URL = require('url');
const ws = require('ws');

const modelToBotUidMapping = {
    'gpt-4': '01c8de4fbfc548df903712b0922a4e01',
    'samantha': '1e3be7fe89e94a809408b1154a2ee3e1',
    'gpt-3.5-turbo': '8077335db7cd47e29f7de486612cc7fd',
    'chatty-ms': '016890537066435ba2befbce559cb776'
};

const roleMapping = {
    'system': 'Instructions',
    'user': 'User',
    'assistant': 'Assistant',
    'function': 'Function'
};

http.createServer((req, res) => {
    const url = URL.parse(req.url);
    var data = "";
    req.on('data', chunk => {
        data += chunk.toString('utf-8');
    });
    req.on('end', () => {
        const j = JSON.parse(data);
        if (url.pathname == '/v1/chat/completions') {
            const sock = new ws.WebSocket('wss://api.myshell.ai/ws/?EIO=4&transport=websocket');
            if (j.stream) res.writeHead(200, { 'Content-Type': 'text/event-stream' });
            var answer = '';
            var text = '';
            const chatcmpl = md5(v4());
            for (const message of j.messages) {
                text += `<|im_end|>\n<|im_start|>${message.role}${message.name ? ` name=${message.name}` : ''}\n${message.content}`;
            }
            text = text.trimEnd();
            const reqId = v4();
            var acceptAnswers = false;
            sock.on('open', async () => {
                sock.send(`40/chat,${JSON.stringify(
                    {
                        token: null,
                        visitorId: md5(v4())
                    }
                )}`);
                sock.send(`42/chat,${JSON.stringify(
                    [
                        'text_chat',
                        {
                            botUid: modelToBotUidMapping[j.model],
                            reqId,
                            sourceFrom: 'myshellWebsite',
                            text
                        }
                    ]
                )}`);
                sock.on('message', async data => {
                    if (data == '2') sock.send('3');
                    data = data.toString();
                    //console.log(data);
                    try {
                        const cmd = data.split(',')[0];
                        const args = JSON.parse(data.split(',').slice(1).join(','));
                        if (cmd == '42/chat' && args[0] == 'text_stream') {
                            answer += args[1].data.text;
                            if (j.stream) res.write(`data: ${JSON.stringify({
                                id: 'chatcmpl-' + chatcmpl,
                                object: 'chat.completion.chunk',
                                model: j.model,
                                created: Date.now(),
                                choices: [
                                    {
                                        delta: {
                                            content: args[1].data.text,
                                            role: 'assistant'
                                        },
                                        index: 0
                                    }
                                ]
                            })}\n\n`);
                        } else if (cmd == '42/chat' && args[0] == 'message_replied') {
                            if (j.stream) {
                                return res.end('data: [DONE]\n\n');
                            }
                            res.writeHead(200, { 'Content-Type': 'application/json' });
                            res.end(JSON.stringify({
                                id: 'chatcmpl-' + chatcmpl,
                                object: 'chat.completion',
                                created: Date.now(),
                                model: j.model,
                                choices: [
                                    {
                                        index: 0,
                                        message: {
                                            role: 'assistant',
                                            content: answer
                                        },
                                        finish_reason: 'stop'
                                    }
                                ],
                                usage: {
                                    prompt_tokens: null,
                                    completion_tokens: null,
                                    total_tokens: null
                                }
                            }));
                        }
                    } catch (error) {

                    }
                });
            });
        }
    });
}).listen(7663);
