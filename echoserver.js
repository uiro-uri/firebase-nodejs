// netモジュールを読み込み、インスタンスを作成
var net = require('net');

// サーバーのイベントハンドラを定義
net.createServer(function (socket) {

    // ソケット経由でメッセージを送出
    socket.write('This is RLS Tech News Echo Server\r\n');

    // データを受信したら、そのままメッセージとして送出
    socket.on('data', function(data) {
        socket.write(data);
    });
}).listen(1337, '127.0.0.1'); // 127.0.0.1の1337番ポートで待機
