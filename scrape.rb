require 'rubygems'
require 'bundler/setup'

require 'mechanize'
require 'pp'

agent = Mechanize.new
agent.user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:29.0) Gecko/20100101 Firefox/29.0'

login_page_url = 'https://7card.jcb.co.jp/Login'
#login_page_url = 'https://7card.jcb.co.jp/iss-pc/member/user_manage/userLogin.html'
login_page = agent.get(login_page_url)
#p login_page

login_form = login_page.form_with(:name => 'loginForm') do |form|
  form.userId = ENV['USERNAME']
  form.password = ENV['PASSWORD']
end
top_page = login_form.submit
#p top_page

details_page_url = 'https://7card.jcb.co.jp/iss-pc/member/details_inquiry/detail.html?detailMonth=0&output=web'
details_page_top = agent.get(details_page_url)
details_page = agent.get(details_page_url)
pays = []
details_page.search('table').each do |t|
  if t['summary'] == "カードご利用明細"
    t.search('tr').each do |tr|
      if _user = tr.search('td.user').first
        pay = {}
        pay[:user] = _user.text
        pay[:day] = Date.parse(tr.search('td.useDay').first.text)
        pay[:ahead] = tr.search('td.useAhead').first.text
        pay[:amount] = tr.search('td.amountPayable').first.text.gsub("\302\240", '').gsub(',', '').to_i
        pays << pay
      end
    end
  end
end
#p pays
sum = 0
pays.each do |pay|
  sum += pay[:amount]
end
puts "未確定分: #{sum}円"
