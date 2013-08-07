var fs = require('fs');
var crypto = require('crypto');
var tls = require('tls');

var certPem = fs.readFileSync('GrowlersPushCert.pem', encoding='ascii');
var keyPem  = fs.readFileSync('GrowlersPushKey.pem', encoding='ascii');
var caCert  = fs.readFileSync('apple-worldwide-developer-relations-certification-authority.cer', encoding='ascii');

var options = { key: keyPem, cert: certPem, ca: [caCert] };

function connectAPN(next) {
	var stream = tls.connect(2195, 'gateway.sandbox.push.apple.com', options, function() {
		next( !steam.authorized, steam);
	});
}

function hextobin(hexstr) {
	var buf = new Buffer(hexstr.length / 2);
	for(var i = 0; i < hexstr.length/2; i++) {
		buf[i] = (parseInt(hexstr[i * 2], 16) << 4) + (parseInt(hexstr[i * 2 + 1], 16));
	}
	return buf;
}

exports.sendPushNotification = function sendPushNotificationToID(deviceToken) {
				var pushnd = {aps: {alert:'One of your Favorite Beers is back!', sound:'default'}};

				var payload = JSON.stringify(pushnd);
				var payloadlen = Buffer.byteLength(payload, 'utf-8');
				var tokenlen = 32;

				var buffer = new Buffer(1 + 4 + 4 + 2 + tokenlen + 2 + payloadlen);

				var i = 0;
				buffer[i++] = 1; // command
				var msgid = 0xbeefcace;
				buffer[i++] = msgid >> 24 & 0xFF;
				buffer[i++] = msgid >> 16 & 0xFF;
				buffer[i++] = msgid >> 8 & 0xFF;
				buffer[i++] = msgid > 0xFF;

				// expiry in epoch seconds (1 hour)
				var seconds = Math.round(new Date().getTime() / 1000) + 1*60*60;
				buffer[i++] = seconds >> 24 & 0xFF;
				buffer[i++] = seconds >> 16 & 0xFF;
				buffer[i++] = seconds >> 8 & 0xFF;
				buffer[i++] = seconds > 0xFF;
				 
				buffer[i++] = tokenlen >> 8 & 0xFF; // token length
				buffer[i++] = tokenlen & 0xFF;
				var token = hextobin(deviceToken);
				token.copy(buffer, i, 0, tokenlen)
				i += tokenlen;
				buffer[i++] = payloadlen >> 8 & 0xFF; // payload length
				buffer[i++] = payloadlen & 0xFF;
				 
				var payload = Buffer(payload);
				payload.copy(buffer, i, 0, payloadlen);
				 
				stream.write(buffer);  // write push notification

/*
				Apple does not return anything from the socket unless there was an error.  In that case Apple server sends you single binary error message with reason code (offending message is identified by the message id you set in push message)  and closes connection immediately after that.
To parse error message. Stream encoding is utf-8, so we get buffer instance as data argument. */

				stream.on('data', function(data) {
				var command = data[0] & 0x0FF;  // always 8
				var status = data[1] & 0x0FF;  // error code
				var msgid = (data[2] << 24) + (data[3] << 16) + (data[4] << 8 ) + (data[5]);
				console.log(command+':'+status+':'+msgid);
 });
}
