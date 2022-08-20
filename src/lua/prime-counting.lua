prime_counting = {}

function prime_counting.tikz_sieve(n, w, p)
   sieved = {}
   for i = 2, p do
      for j = i, n // i do
         if sieved[i * j] == nil then
            sieved[i * j] = i
         end
      end
   end
   for i = 2, n do
      y = -((i - 1) // w)
      x = (i - 1) % w

      if true then
         tex.print('\\begin{scope}')
         tex.print(string.format('[shift={(%f, %f)}, scale={0.5}]', x, y))
         tex.print('\\draw (-1, -1) -- (-1, 1) -- (1, 1) -- (1, -1) -- cycle;')
         tex.print('\\end{scope}')
      end
      fg = 'black'
      if sieved[i] ~= nil then
         if sieved[i] == p then
            style = 'pattern=north east lines, pattern color=red'
            style = 'color=black, fill=ThomasRed!50!white'
            fg = 'white'
         else
            style = 'pattern=north east lines, pattern color=black'
         end
         tex.print('\\begin{scope}')
         tex.print(string.format('[shift={(%f, %f)}, scale={0.5}]', x, y))
         tex.print(string.format('\\draw[%s] (-1, -1) -- (-1, 1) -- (1, 1) -- (1, -1) -- cycle;', style))
         tex.print('\\end{scope}')
      end
      tex.print(string.format('%s[%s] at (%f, %f) {\\small %.0f};', '\\node', fg, x, y, i))
   end
end

function prime_counting.tikz_log_sieve(n, l, p)
   sieved = {}
   for i = 2, p do
      for j = i, n // i do
         if sieved[i * j] == nil then
            sieved[i * j] = i
         end
      end
   end

   eps = 0.1
   sixth = math.log(n, l) / 6
   -- main line
   tex.print(string.format('\\draw (%f, 0) -- (%f, 0);', -2 * eps, math.log(n, l) + 2 * eps))

   -- ticks
   for i = 0, 6 do
      tex.print(string.format('\\draw (%f, %f) -- (%f, %f);', i * sixth, -eps, i * sixth, eps))
   end
   tex.print(string.format('\\node at (%f, %f) {\\scriptsize $n^{1/6}$};', sixth, 3 * eps))
   tex.print(string.format('\\node at (%f, %f) {\\scriptsize $n^{1/3}$};', 2 * sixth, 3 * eps))
   tex.print(string.format('\\node at (%f, %f) {\\scriptsize $n^{1/2}$};', 3 * sixth, 3 * eps))
   tex.print(string.format('\\node at (%f, %f) {\\scriptsize $n^{2/3}$};', 4 * sixth, 3 * eps))
   tex.print(string.format('\\node at (%f, %f) {\\scriptsize $n$};', 6 * sixth, 3 * eps))

   for i = 2, n do
      if sieved[i] == nil then
         if i < p then
            tex.print(string.format('\\node[circle, draw=pro, fill=white, radius=1px, inner sep=0pt] at (%f, 0) {};', math.log(i, l)))
         elseif i == p then
            tex.print(string.format('\\node[circle, draw=pro, fill=pro, radius=1px, inner sep=0pt] at (%f, 0) {};', math.log(i, l)))
         end    
      else
         if sieved[i] < p then
            tex.print(string.format('\\node[circle, draw=ThomasRed, fill=ThomasRed, radius=1px, inner sep=0pt] at (%f, 0) {};', math.log(i, l)))
         elseif sieved[i] == p then
            tex.print(string.format('\\node[circle, draw=con, fill=con, radius=1px, inner sep=0pt] at (%f, 0) {};', math.log(i, l)))
         end
      end
   end

   for i = 1, math.floor(math.sqrt(n)) do
      x = n // i
      y = -0.5
      tex.print(string.format('\\node[circle, fill, gray, radius=1px, inner sep=0pt] at (%f, %f) {};', math.log(x, l), y))
      -- tex.print(string.format('\\node at (%f, %f) {%.0f};', math.log(x, l), y - 0.1 * i, x))
      x = i
      tex.print(string.format('\\node[circle, fill, gray, radius=1px, inner sep=0pt] at (%f, %f) {};', math.log(x, l), y))
   end

   tex.print(string.format('\\node at (%f, %f) {\\tiny \\textcolor{pro}{%.0f}};', math.log(p, l), -1, p))
   tex.print(string.format('\\node at (%f, %f) {\\tiny \\textcolor{pro}{%.0f}};', math.log(n, l), -1, n))
end

function prime_counting.x_div_by(n, l, d)
   x = math.floor(n/d)
   return math.log(x, l)
end

function prime_counting.tikz_dp_trans(l, ds, dt, y, src, dst)
   xs = math.floor(ds)
   xt = math.floor(dt)
   sty = 'inner sep=1.5pt'
   edge = ''
   if math.log(xt, l) - math.log(xs, l) > 0.5 then
      edge = 'bend right'
   end
   tex.print(string.format('\\node[%s] (%s) at (%f, %f) {\\tiny %.0f};', sty, dst, math.log(xt, l), y, xt))
   tex.print(string.format('\\node[%s] (%s) at (%f, %f) {\\tiny %.0f};', sty, src, math.log(xs, l), y, xs))
   tex.print(string.format('\\path[draw=black, ->] (%s) edge [%s] (%s);', src, edge, dst))
end

function prime_counting.tikz_lucy(n, l, pi_k, dst)
   -- どこが律速になってるかわからないけど、毎回 DP するの自体は無駄なので、
   -- 毎ループで遷移を記録しておくのを一回だけ走らせておけばよい？
   -- まぁでも書き直すの面倒だからねえ。
   -- 点を打つ（TikZ の描画）パートが律速なら意味ないし。
   dp = {}
   a = {}
   last = {}
   n_2 = math.floor(math.sqrt(n))
   for i = 1, n_2 do
      a[i] = n // i
   end
   for i = 1, n // n_2 do
      a[n_2 + i] = n // n_2 - i
   end

   len = n_2 + (n // n_2)
   for i = 1, len do
      dp[i] = a[i] - 1
      last[i] = 1
   end

   -- 篩を書くよりは手書きの方が楽なのでそうしてしまった
   primes = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29}
   lpf = {0, 2, 3, 2, 5, 2, 7, 2, 3, 2, 11, 2, 13, 2, 3, 2, 17, 2, 19, 2, 3, 2, 23, 2, 5, 2, 3, 2, 29, 2, 31, 2, 3, 2, 5, 2, 37, 2, 3, 2, 41, 2, 43, 2, 3, 2, 47, 2, 7, 2, 3, 2, 53, 2}
   n_3 = math.pow(n, 1 / 3)
   n2_3 = math.pow(n, 2 / 3)
   n_6 = math.pow(n, 1 / 6)

   for pi = 1, pi_k - 1 do
      p = primes[pi]
      for i = 1, len do
         if a[i] < p * p then break end
         if n_6 < primes[pi_k] and primes[pi_k] < n_3 and p > n_6 then
            if i > math.floor(n_3) then break end
         end
         if i * p <= n_2 then
            j = i * p
         else
            j = len - a[i] // p
         end

         lpf_n = 0
         if n_6 < primes[pi_k] and primes[pi_k] < n_3 then
            if n_6 < p and p < n_3 and a[j] < n2_3 then
               for x = 1, a[j] do
                  if n_6 < lpf[x] and lpf[x] < p and lpf[x] < x then
                     lpf_n = lpf_n + 1
                  end
               end
            end
         end

         dp[i] = dp[i] - (dp[j] - lpf_n - (pi - 1))
         last[i] = p
         -- break しちゃうから、last[i] が古くなっちゃうかも
      end
   end

   i = dst
   pi = pi_k
   p = primes[pi]
   if a[i] < p * p then return end
   if n_6 < p and p < n_3 and a[i] < n2_3 then return end

   if i * p <= n_2 then
      j = i * p
   else
      j = len - a[i] // p
   end

   lpf_n = 0
   if n_6 < p and p < n_3 and a[j] < n2_3 then
      lpf_s = ''
      for x = 1, a[j] do
         if n_6 < lpf[x] and lpf[x] < p and lpf[x] < x then
            if lpf_n == 0 then
               lpf_s = string.format('%.0f', x)
               lpf_n = 1
            else
               lpf_s = lpf_s .. string.format(', %.0f', x)
               lpf_n = lpf_n + 1
            end
         end
      end

      -- この辺どうにかしたいねえ
      tex.print(string.format('\\node[right] at (0, -2) {$ \\underbrace{\\DP[%.0f]}_{\\substack{\\scriptscriptstyle S_{%.0f}(%.0f)\\\\\\scriptscriptstyle {}=%.0f}} \\xgets{-} \\underbrace{\\DP[%.0f]}_{\\substack{\\scriptscriptstyle S_{%.0f}(%.0f)\\\\\\scriptscriptstyle {}=%.0f}} - \\underbrace{|\\{{\\scriptscriptstyle v\\in(\\mathbb{N}\\setminus\\mathbb{P})\\,\\mid\\, v\\le %.0f, \\sqrt[6]{n}<\\lpf{v}<%.0f}\\}|}_{\\substack{\\scriptscriptstyle|\\{%s\\}|\\\\\\scriptscriptstyle{}=%.0f}} - \\underbrace{\\pi(%.0f-1)}_{\\scriptscriptstyle %.0f} $};',
                              i, last[i], a[i], dp[i],
                              j, last[j], a[j], dp[j],
                              a[j], p, lpf_s, lpf_n,
                              p, pi - 1))
   else
      tex.print(string.format('\\node[right] at (0, -2) {$ \\underbrace{\\DP[%.0f]}_{\\substack{\\scriptscriptstyle S_{%.0f}(%.0f)\\\\\\scriptscriptstyle {}=%.0f}} \\xgets{-} \\underbrace{\\DP[%.0f]}_{\\substack{\\scriptscriptstyle S_{%.0f}(%.0f)\\\\\\scriptscriptstyle {}=%.0f}} - \\underbrace{\\pi(%.0f-1)}_{\\scriptscriptstyle %.0f} $};',
                              i, last[i], a[i], dp[i],
                              j, last[i], a[j], dp[j],
                              p, pi - 1))
   end

   if n_6 < p and p < n_3 and a[j] < n2_3 then
      tex.print(string.format('\\path[draw=black, {Rays[n=2]}-{Rays[n=2]}] (0, -.25) -- (%f, -.25);', math.log(a[j], l)))
   end

   dp[i] = dp[i] - (dp[j] - lpf_n - (pi - 1))

   tex.print(string.format('\\node[right] at (0, -3.5) {$ \\DP[%.0f] = S_{%.0f}(%.0f) = %.0f $};', i, p, a[i], dp[i]))
   tikz_dp_trans(l, a[j], a[i], -.75, 'src', 'dst')
end

function prime_counting.tikz_lucy_fix(n, l, dst)
   dp = {}
   a = {}
   last = {}
   n_2 = math.floor(math.sqrt(n))
   for i = 1, n_2 do
      a[i] = n // i
   end
   for i = 1, n // n_2 do
      a[n_2 + i] = n // n_2 - i
   end

   len = n_2 + (n // n_2)
   for i = 1, len do
      dp[i] = a[i] - 1
      last[i] = 1
   end

   primes = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29}
   lpf = {0, 2, 3, 2, 5, 2, 7, 2, 3, 2, 11, 2, 13, 2, 3, 2, 17, 2, 19, 2, 3, 2, 23, 2, 5, 2, 3, 2, 29, 2, 31, 2, 3, 2, 5, 2, 37, 2, 3, 2, 41, 2, 43, 2, 3, 2, 47, 2, 7, 2, 3, 2, 53, 2}
   n_3 = math.pow(n, 1 / 3)
   n2_3 = math.pow(n, 2 / 3)
   n_6 = math.pow(n, 1 / 6)
   pi_k = math.floor(n_3)
   p_6 = 0

   for pi = 1, pi_k do
      p = primes[pi]
      if p > n_3 then break end
      if p_6 == 0 and p > n_6 then
         p_6 = primes[pi - 1]
      end

      for i = 1, len do
         if a[i] < p * p then break end
         if p > n_6 then
            if i > math.floor(n_3) then break end
         end
         if i * p <= n_2 then
            j = i * p
         else
            j = len - a[i] // p
         end

         lpf_n = 0
         if n_6 < primes[pi_k] and primes[pi_k] < n_3 then
            if n_6 < p and p < n_3 and a[j] < n2_3 then
               for x = 1, a[j] do
                  if n_6 < lpf[x] and lpf[x] < p and lpf[x] < x then
                     lpf_n = lpf_n + 1
                  end
               end
            end
         end

         dp[i] = dp[i] - (dp[j] - lpf_n - (pi - 1))
         last[i] = p
         -- break しちゃうから、last[i] が古くなっちゃうかも
      end
   end

   i = dst
   p = primes[pi]
   -- if a[i] < p * p then return end
   -- if n_6 < p and p < n_3 and a[i] < n2_3 then return end

   if i * p <= n_2 then
      j = i * p
   else
      j = len - a[i] // p
   end

   lpf_n = 0
   lpf_s = ''
   for x = 1, a[i] do
      if n_6 < lpf[x] and lpf[x] <= p and lpf[x] < x then
         if lpf_n == 0 then
            lpf_s = string.format('%.0f', x)
            lpf_n = 1
         else
            lpf_s = lpf_s .. string.format(', %.0f', x)
            lpf_n = lpf_n + 1
         end
      end
   end

   -- 実際は last[i] じゃなくて n^{1/6} 以下の最大の素数を持ってくる必要あり。
   -- 今回は 2 なのでたまたまうまくいってそう。
   -- i が小さいと last[i] == 1 になって困った。まぁ更新しなくてもいいんですが。
   tex.print(string.format('\\node[right] at (0, -2) {$ \\underbrace{\\DP[%.0f]}_{\\substack{\\scriptscriptstyle S_{%.0f}(%.0f)\\\\\\scriptscriptstyle {}=%.0f}} \\xgets{-} \\underbrace{|\\{{\\scriptscriptstyle v\\in(\\mathbb{N}\\setminus\\mathbb{P})\\,\\mid\\, v\\le %.0f, \\sqrt[6]{n}<\\lpf{v}<n^{2/3}}\\}|}_{\\substack{\\scriptscriptstyle|\\{%s\\}|\\\\\\scriptscriptstyle{}=%.0f}} $};',
                           i, p_6, a[i], dp[i],
                           a[i], lpf_s, lpf_n))

   tex.print(string.format('\\path[draw=black, {Rays[n=2]}-{Rays[n=2]}] (0, -.25) -- (%f, -.25);', math.log(a[i], l)))

   dp[i] = dp[i] - lpf_n

   tex.print(string.format('\\node[right] at (0, -3.5) {$ \\DP[%.0f] = S_{%.0f}(%.0f) = %.0f $};', i, p, a[i], dp[i]))
   tex.print(string.format('\\node at (%f, %f) {\\tiny %.0f};', math.log(a[i], l), -.75, a[i]))
end
