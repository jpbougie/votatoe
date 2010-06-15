# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :vote do |f|
  f.status_id "MyString"
  f.author_id "MyString"
  f.poll_id 1
  f.agent "MyString"
  f.location "MyString"
end
