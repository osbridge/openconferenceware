/*---[ data structure conveniences ]----------------------------------*/

// Return an array of keys in +hash+. Example:
//  hash_keys({'foo': 'bar', 'baz': 'qux'}); // ['foo', 'baz']
function hash_keys(hash) {
  array = new Array();
  for (key in hash) {
    if (key) {
      array.push(key);
    }
  }
  return array;
}

// Return hash where each key is an element of the +array+. Example:
//    array_to_hash(['foo', 'bar']); // {'foo': true, 'bar': true}
function array_to_hash(array) {
  hash = new Array();
  for (i in array) {
    hash[array[i]] = true;
  }
  return hash;
}
