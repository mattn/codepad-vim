
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
  let content = join(getline(a:line1, a:line2), "\n")
  if has_key(s:detectLang, &ft)
    let type = s:detectLang[&ft]
  else
    let type = ""
  endif
  let type = len(type) ? type : 'Plain Text'
  let res = http#post('http://codepad.org/', {
  \ 'lang'  : type,
  \ 'code'   : content,
  \ 'run'    : 'True',
  \ 'submit' : 'Submit',
  \})
  let mx = "^.*<a name=\"output\">.*<pre>\\s*\<NL>\\zs.*\\ze</pre>\\=.*$"
  let content = substitute(matchstr(res.content, mx), '<[^>]+', '', 'g')
  let content = html#decodeEntityReference(content)
  echo content
endfunction

command! -nargs=? -range=% CodePadRun :call CodePadRun(<line1>, <line2>)

