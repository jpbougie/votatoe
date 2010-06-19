# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :poll do |f|
  f.status_id 1
  f.user_id 1
  f.text "MyString"
end
