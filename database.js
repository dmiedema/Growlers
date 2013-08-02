var db = require('mongojs').connect('localhost', ["Favorites", "Beers"]);

exports.favorite = function(beer) {
    return findBeer(beer);
  };

exports.unfavorite = function(beer) {
    return findBeer(beer);
  };

exports.checkForNewBeers = function(newList, callback) {
  notifyUsersOfNewBeers(newList, callback);
}

exports.setAvailableBeers = function(beerList) {
  console.log('update avaiable beers');
  console.log(beerList);
    return setBeerList(beerList);
  }

function findBeer(beer) {
  db.Favorites.findOne({'beer.name': beer.name, 'beer.brewer': beer.brewer}, function(err, result) {
    if (err) { console.log(err); return false; }
    else {
      console.log('findBeer result -');
      console.log(result);
      if (beer.fav == false && !result ) { return false; }
      else if (!result) {
        //create
        create(beer);
      } else if (beer.fav == false) {
        // delete
        deleteBeer(beer);
      } else {
        // add entr
        add(beer);
      }
    }
  });
}

function add(entry) {
  console.log('add - entry - ' + entry);
  //var beer = entry;
  //if ((typeof beer) == 'undefined') create(entry);
  //entry.favorites.push(entry.udid);
  db.Favorites.update(
    {'beer.name': entry.name, 'beer.brewer': entry.brewer},
    { $push: {favorites: entry.udid} },
    (function(err) {
      // update done
      if(err) {
        console.log('Error updating ' + entry);
        console.log(err);
        return false;
      } else {
        console.log(entry + ' updated successfully');
      }
    })
  ); // end update
  return true;
}

function deleteBeer(entry) {
  console.log('delete - entry - ' + entry);
  // var beer = entry;
  // if ((typeof beer) == 'undefined') return;
  db.Favorites.update(
    {'beer.name': entry.name, 'beer.brewer': entry.brewer},
    {$pull: {favorites: entry.udid} },
    (function (err) {
      if(err) {
        console.log('Error removing ' + entry);
        console.log(err);
        return false;
      } else {
        console.log( entry + ' removed successfully');
      }
    })
  );
  db.Favorites.remove({favorites: []}, function(err, result) {
    if (err) { console.log('Error removing entries with no favories'); }
    else {
      console.log('Entries with no favories cleaned out.');
    }
  });
  return true;
} // end delete

function create(entry) {
  console.log('create - entry - ' + entry);
  db.Favorites.save(
    {beer: {
      name: entry.name,
      brewer: entry.brewer},
    favorites: [(entry.udid)]
  }, function(err, saved) {
    if (err || !saved) {
      console.log('error creating ' + entry);
      console.log(err);
      return false;
    } else {
      console.log(entry + ' created');
    }
  });
  return true;
}

function notifyUsersOfNewBeers(newList, callback) {
  console.log('Notify Users of New Beers');
  if (typeof callback === 'function') {
    db.Beers.find(function(err, result) {
      if(err || !result) { console.log("error getting old beer list"); }
      else {
        console.log('Beers.find() result');
        console.log(result[0].beerList);
        callback(result[0].beerList, newList);
      }
    });
  }
}

function setBeerList(newlist) {
  console.log('Set Beer List');
  console.log(newlist);
  db.Beers.drop();
  db.Beers.save( {
    beerList: newlist
  }, function(err, saved) {
    if (err || !saved) {
      console.log('error saving beer list');
    } else {
      console.log('beer list saved');
    }
  });
}
