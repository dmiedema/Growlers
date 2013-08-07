/* Nodefly stuff */
var hostname = require('os').hostname();
var processNumber = process.env.INDEX_OF_PROCESS || 0;

require('strong-agent').profile(
	'd402a97cd5720507a219fe4f602ba5e3', // my api token
	['Growl-Server', hostname, processNumber]
);

var http = require('http');
var db   = require('./database');
/* Push Stuff */
var pushstuff = require('./push-notifications');

var response = '';
var html;

var beerJSON = [];

setInterval(getData(), (1000*60)*10);

function getData() {
  console.log('' + timeStamp(new Date())  + 'Requesting Data from Growl Movement...');
  http.get('http://www.growlmovement.com/taplist/', function(res) {
    res.on('data', function(chunk) {
      response = response.concat(chunk.toString());
    });
    res.on('end', function() {

      html = response;

      var start = html.indexOf('class="tabltap"'); // returns index of that element

      var end = html.indexOf('</table>');

      var content = html.slice(start, end);

      var list = content.split('<tr');
      list.shift();
      list.shift();

      list.forEach(function(item) {

        listItems = item.split('<td');
        var beerInfo = listItems[2];
        var cost = listItems[3];
        var beerName = getBeerName(beerInfo);
        var brewer = getBrewer(beerInfo);
        var brewURL = getBeerURL(beerInfo);
        var ibu = getIBUs(beerInfo);
        var abv = getABV(beerInfo);
        var costs = getBeerCost(cost);
        beerJSON.push({
          "name" : beerName,
          "brewer": brewer,
          "brew_url" : brewURL,
          "ibu" : ibu,
          "abv" : abv,
          "growler" : costs.growler,
          "growlette" : costs.growlette
        });
      }); // end forEach
      notifyUsers(beerJSON);
    }); // end res.end
  });
  console.log('' + timeStamp(new Date()) + 'Data Received from Growl Movement.');
}

function timeStamp(date) {
  return "" + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds() + " - " + date.getDate() + "/" + date.getMonth() + "/" + date.getFullYear() + "  --  ";
}

function getBeerName(beer) {
	return beer.split('<b>')[1].split('</b>')[0];
}

function getBrewer(beer) {
	console.log(beer);
	var brewer = beer.split('<a')[1];
	console.log(brewer)
	console.log(brewer);
	if(brewer) { 
	  return beer.split('<a')[1].split('</a')[0].split('>')[1]; 
	}
	else {
		return beer.split(' - ')[1].split('<')[0];
	}
  return '';
}

function getBeerURL(beer) {
	var brewerURL = beer.split('href=')[1];
	if (brewerURL) {
		return brewerURL.split(' ')[0];
	}
	else {
		return '';
	}  
}

function getOtherBeerInfo(beer) {
  return beer.split('<br')[1] || '';
}

function getIBUs(beer) {
  var IBU = getOtherBeerInfo(beer);
  if(!IBU) return '';
  var ibu = IBU.toLowerCase().split('ibu:')[1];
  if(ibu) return ibu.split('abv:')[0].trim();
  else return ''
}
function getABV(beer) {
  var ABV = getOtherBeerInfo(beer);
  if(!ABV) return '';
  var abv = ABV.toLowerCase().split('abv:')[1]
  if(abv) return abv.split('</')[0].trim();
  else return '';
}

function getBeerCost(beer) {
  var costs = beer.split('/');
  var growler = costs[0].split('>')[2].trim();
  var growlette = costs[1].split('<')[0].trim();
  return {
    "growler" : growler.substr(5), // strip off all of '&#36;'
    "growlette" : growlette.substr(5)
  };
}

function notifyUsers(newList) {
  db.checkForNewBeers(newList, function(oldBeers, newBeers) {
    console.log('' + timeStamp(new Date()) + ' -- Checking for new beers');
    for(var i = 0; i < newBeers.length; i++) {
      var flag = false;
      for(var j = 0; j < oldBeers.length; j++) {
				flag = oldBeers[j].name == newBeers[i].name && oldBeers[j].brewer == newBeers[i].brewer;
				if (flag == true) break;
      }
      if (!flag) { 
				//TODO: Push notification firing will go here
				var favs = newBeers[i].favorites;
				for(var c = 0; c < favorites.length; c++) {
					pushstuff.sendPushNotification(favorites[c]);
				}
      } 
    } // end outer for
    db.setAvailableBeers(newList);
  });
} // end function

var requestListener = function(req, res) {
  if (req.method == 'GET') {
		res.writeHead(200,{
			"Content-Type": "application/json"
		});
		res.write(JSON.stringify(beerJSON));
		res.end();
  } // end 'GET'
	else if (req.method == 'POST') {
		var request = ''; // create var request so i can reference later
		req.on('data', function(chunk) {
			request = request.concat(chunk.toString());
		}); // end on 'data'
		req.on('end', function() {
			request = JSON.parse(request);
			if (request.fav == true) {
				db.favorite(request);
				res.writeHead(200,{
					"Content-Type": "application/json"
				});
			}
			else {
				db.unfavorite(request);
				res.writeHead(200, {
					"Content-Type": "application/json"
				});
			}
			res.end(JSON.stringify({complete: true}));
		}); // end on 'end'
	}
	else { // invalid request
		res.writeHead(500);
		res.end(JSON.stringify({'error': 'invalid HTTP method'}));
	}

}

var server = http.createServer(requestListener);
server.listen(8000);
