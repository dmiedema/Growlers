var db = require('mongoose');
db.connect('mongodb://localhost/GrowlMovement');

var favoriteSchema = db.Schema({
  beer: {name: String, brewery: String},
  favorites: Array
});

var Favorite = db.model('Favorite', favoriteSchema);

module.exports = {
  find: function(fav) {
    return Favorite.findOne({'beer.name': fav.beername, 'beer.brewery': fav.brewery}).count() == true;
  }
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
  unfavorite: function(beer) {
    // TODO: find matching beer, remove UDID from favorites, save it.
  }
};


