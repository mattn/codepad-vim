
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

function!  s:stripTags(str)
  return substitute(a:str, '<[^>]+>', '', 'g')
endfunction

function!  s:decodeHtml(str)
  let str = a:str
  let str = substitute(str, '&gt;', '>', 'g')
  let str = substitute(str, '&lt;', '<', 'g')
  let str = substitute(str, '&quot;', '"', 'g')
  let str = substitute(str, '&apos;', "'", 'g')
  let str = substitute(str, '&nbsp;', ' ', 'g')
  let str = substitute(str, '&yen;', '\&#65509;', 'g')
  let str = substitute(str, '&#\(\d\+\);', '\=s:Uni_nr2enc_char(submatch(1))', 'g')
  let str = substitute(str, '&amp;', '\&', 'g')
  return str
endfunction

function! s:nr2hex(nr)
  let n = a:nr
  let r = ""
  while n
    let r = '0123456789ABCDEF'[n % 16] . r
    let n = n / 16
  endwhile
  return r
endfunction

function! s:encodeURIComponent(instr)
  let instr = iconv(a:instr, &enc, "utf-8")
  let len = strlen(instr)
  let i = 0
  let outstr = ''
  while i < len
    let ch = instr[i]
    if ch =~# '[0-9A-Za-z-._~!''()*]'
      let outstr = outstr . ch
    elseif ch == ' '
      let outstr = outstr . '+'
    else
      let outstr = outstr . '%' . substitute('0' . s:nr2hex(char2nr(ch)), '^.*\(..\)$', '\1', '')
    endif
    let i = i + 1
  endwhile
  return outstr
endfunction

function! CodePadRun(line1, line2)
  let content = join(getline(a:line1, a:line2), "\n")
  let type = s:detectLang[&ft]
  let type = len(type) ? type : 'Plain Text'
  let query = [
    \ 'lang=%s',
    \ 'code=%s',
    \ 'run=True',
    \ 'submit=Submit',
    \ ]

  let squery = printf(join(query, '&'),
    \ s:encodeURIComponent(type),
    \ s:encodeURIComponent(content))
  unlet query
  let file = tempname()
  exec 'redir! > '.file 
  silent echo squery
  redir END
  let quote = &shellxquote == '"' ?  "'" : '"'
  let url = 'http://codepad.org/'
  let res = system('curl -i -d @'.quote.file.quote.' '.url)
  call delete(file)
  let res = matchstr(split(res, '\(\r\?\n\|\r\n\?\)'), '^location: ')
  let res = substitute(res, '^.*: ', '', '')
  if len(res) > 0
	if res =~ '^/'
      let res = 'http://codepad.org'.res
	endif
    let res = system('curl -s '.res)
    let res = substitute(res, "^.*<a name=\"output\">.*<pre>\\s*\<NL>\\(.*\\)</pre>\\=.*$", '\1', '')
    let res = s:stripTags(res)
    let res = s:decodeHtml(res)
	echo res
  else
    echoerr 'Running failed'
  endif
endfunction

command! -nargs=? -range=% CodePadRun :call CodePadRun(<line1>, <line2>)

