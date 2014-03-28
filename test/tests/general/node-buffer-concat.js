// Copyright Joyent, Inc. and other Node contributors.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.

define([], function() { return function(){
var zero = [];
var one  = [ new Buffer('asdf') ];
var _long = [];
for (var i = 0; i < 10; i++) _long.push(new Buffer('asdf'));

var flatZero = Buffer.concat(zero);
var flatOne = Buffer.concat(one);
var flatLong = Buffer.concat(_long);
var flatLongLen = Buffer.concat(_long, 40);

assert(flatZero.length === 0);
assert(flatOne.toString() === 'asdf');
assert(flatOne === one[0]);
assert(flatLong.toString() === (new Array(10+1).join('asdf')));
assert(flatLongLen.toString() === (new Array(10+1).join('asdf')));
};});