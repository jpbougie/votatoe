# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :tweet do |f|
  f.status_id 1
  f.payload "MyText"
end
