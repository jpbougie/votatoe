// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function fetchLists() {
  $.ajax({
    url: location.href + '/lists.json',
    success: function(data) {
      console.debug(data)
      ul = $('<ul>')
      _.each(data, function(count, slug) {
        ul.append($('<li>').html(slug + ' ' + count))
      })
      $('#filter-options').html(ul)
    },
    dataType: "json"
  });
  
  return false
}