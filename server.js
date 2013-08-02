var http = require('http');
var db = require('./database');

var response = '';
var html;

var beerJSON = [];

//setTimeout(getData(), (1000*60)*10);

function getData() {
  console.log('' + timeStamp(new Date()) + 'Requesting Data from Growl Movement...');
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
      });
      notifyUsers(beerJSON);
    }); // on res.end
  }); // http.get
}

getData();
function timeStamp(date) {
  return "" + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds() + " - " + date.getDate() + "/" + date.getMonth() + "/" + date.getFullYear() + " -- ";
}

function getBeerName(beer) {
  var start = beer.split('<b>')[1];
  var name = start.split('</b>')[0];
  return name;
}

function getBrewer(beer) {
  return beer.split('<a')[1].split('</a>')[0].split('>')[1];
}

function getBeerURL(beer) {
  return beer.split('href=')[1].split(' ')[0];
}

function getOtherBeerInfo(beer) {
  return beer.split('<br')[1];
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
  var costs = beer.split('&#36;');
  var growler = costs[1].split(' ')[0];
  var growlette = costs[2].split('<')[0];
  return {
    "growler" : growler,
    "growlette" : growlette
  };
}

function notifyUsers(newList) {
  db.checkForNewBeers(newList, function(oldBeers, newBeers) {
    console.log('CHECK FOR NEW BEERS');
    console.log(oldBeers);
    console.log(newBeers);
    for (var i = 0; i < newBeers.length; i++) {
      var flag = false;
      for (var j = 0; j < oldBeers.length; j++) {
        flag = oldBeers[i].name == newBeers[j].name && oldBeers[i].brewer == newBeers[j].brewer;
        if (flag == true) break;
      }
      console.log('flag - '  + flag);
      if (!flag) {
        //TODO: notify
      }
    } // end oldBeers forEach
    db.setAvailableBeers(newList);
  });

  //db.setAvailableBeers(newList);
}


/* Request Listener */
var requestListener = function(req, res) {
  // TODO: Handle POST
  if (req.method == "GET") {
    res.writeHead(200, {
      "Content-Type": "application/json"
    });
    res.write(JSON.stringify(beerJSON));
    res.end();
  }
  else if (req.method == "POST") {
    var request; // create var request so I can reference later.
    req.on('data', function(chunk) {
      // request gets the data as a string
      request = chunk.toString();
    });
    req.on('end', function() {
      // JSON.parse resulting string
      request = JSON.parse(request);
      if (request.fav == true) {
        // if (db.favorite(request)) res.writeHead(200);
        // else res.writeHead(500)
        db.favorite(request);
        res.writeHead(200);
      }
      else {
        // if (db.unfavorite(request)) res.writeHead(200);
        // else res.writeHead(500);
        db.unfavorite(request);
        res.writeHead(200);
      }
      res.end(JSON.stringify({complete: true})); //, action:(request.fav) ? "favorite" : "unfavorite"}));
    });
  }
  else {
    res.writeHead(500);
    res.end("Error -- Invalid Method");
  }
}

var server = http.createServer(requestListener);
server.listen(8000);
