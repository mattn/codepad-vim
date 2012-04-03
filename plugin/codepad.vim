
let s:detectLang = {
 \ 'c' : 'C',
 \ 'cpp' : 'C++',
 \ 'd' : 'D',
 \ 'haskell' : 'Haskell',
 \ 'lua' : 'Lua',
 \ 'ocaml' : 'Ocaml',
 \ 'php' : 'PHP',
 \ 'perl' : 'Perl',
 \ 'python' : 'Python',
 \ 'ruby' : 'Ruby',
 \ 'scheme' : 'Scheme',
 \ }

function! CodePadRun(line1, line2)
  let res = webapi#http#post('http://codepad.org/', {
  \ 'lang'  : get(s:detectLang, &ft, 'Plain Text'),
  \ 'code'   : join(getline(a:line1, a:line2), "\n"),
  \ 'run'    : 'True',
  \ 'submit' : 'Submit',
  \})
  let mx = "^.*<a name=\"output\">.*<pre>\\s*\<NL>\\zs.*\\ze</pre>\\=.*$"
  let content = substitute(matchstr(res.content, mx), '<[^>]+', '', 'g')
  let content = webapi#html#decodeEntityReference(content)
  echo content
endfunction

command! -nargs=? -range=% CodePadRun :call CodePadRun(<line1>, <line2>)

