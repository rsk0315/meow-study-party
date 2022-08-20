latest_commit = {}

function latest_commit.get_latest_commit(options, name)
   -- shell injection について callee で気をつけてないので注意！
   local handle = io.popen('git log -n1 ' .. options .. ' ' .. name)
   local result = handle:read('*a')
   handle:close()
   return result
end

function latest_commit.commit_hash_and_date(name)
   options = "--format='\\footnotesize{%cd} (\\texttt{\\scriptsize %h})' --date=format:'%b.~%d %H:%M, %Y'"
   res = latest_commit.get_latest_commit(options, name)
   res, _ = string.gsub(res, '\n', '')
   if res == '' then
      tex.print(string.format('{\\scriptsize (\\emph{untracked})}'))
      return
   end
   res, _ = string.gsub(res, 'May.', 'May')
   res, _ = string.gsub(res, '~0', '~')
   tex.print(string.format('%s', res))
end
