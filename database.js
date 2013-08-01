var db = require('mongojs').connect('localhost', ["Favorites"]);

/*
var favoriteSchema = db.Schema({
  beer: {name: String, brewery: String},
  favorites: Array
});

var Favorite = db.model('Favorite', favoriteSchema);
*/

module.exports = {
  find: function(beer) {
    return findBeer(beer);
  },

  exists: function(beer) {
    return beerExists(beer);
  },

  favorite: function(beer) {
    if (beerExists(beer)) {
      return add(beer);
    } else {
      return create(beer);
    }
  },
  /*
  insert: function(fav, createEntry) {
    var create;
    if (typeof(createEntry) === 'undefined')
      create = true;
    else create = createEntry;

    if(create) {
      var beer = new Favorite({beer: {name: fav.beername, brewery: fav.brewery}, favorites: [fav.uniqueID]});
      beer.save(function(error, favorite) {
        if (error) {
          // error, handle it.
        }
      });
    } else {
      var found = Favorite.findOne({'beer.name': fav.beername, 'beer.brewery': fav.brewery});
      found.favorites.push(fav.uniqueID);
      Favorite.save(found);
    }
  }
  */
  unfavorite: function(beer) {
    // TODO: find matching beer, remove UDID from favorites, save it.
    return deleteBeer(beer);
  }
};
function beerExists(beer) {
  return findBeer(beer) === null;
}

function findBeer(beer) {
  return db.Favorites.findOne({'beer.name': beer.beername, 'beer.brewery': beer.brewery});
}

function add(entry) {
  var beer = findBeer(entry);
  if ((typeof beer) == 'undefined') create(entry);
  beer.favorites.push(entry.uniqueID);
  db.Favorites.update(
    {'beer.name': entry.beername, 'beer.brewery': entry.brewery},
    { $push: {favorites: entry.uniqueID} },
    (function(err) {
      // update done
      if(err) { return false; }
    })
  ); // end update
  db.Favorites.save();
  return true;
}

function deleteBeer(entry) {
  var beer = findBeer(entry);
  if ((typeof beer) == 'undefined') return;
  for(var i = 0; i < beer.favorites.length; i++) {
    if (beer.favorites[i] == entry.uniqueID) {
      beer.favorites.splice(i, 1); }
    if (beer.favorites.length > 1) {
      // delete entry
      beer.save(function(err, favorite) {
        if(err) { return false; }
      });
    } else {
      beer.save(function(err, favorite) {
        if(err) { return false; } // handle error
      });
    }
  }
  return true;
} // end delete

function create(entry) {
  db.Favorites.save(
    {beer: {
      name: entry.beername,
      brewery: entry.brewery},
    favorites: [entry.uniqueID]
  }, function(err, saved) {
    if (err || !saved) {
      console.log('error creating ' + entry);
      return false;
    }
  });
/*
  db.Favorites.save();
  var beer = new Favorite({beer: {name: entry.beername, brewery: entry.brewery}, favorites: [entry.uniqueID]});
  beer.save(function(err, favorite) {
    if(err) {
      //handle error
    }
  });
*/
  return true;
}
