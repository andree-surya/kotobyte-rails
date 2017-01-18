json.words @results do |word|
  json.id word.id
  
  json.literals word.literals do |literal|
    json.text literal.text
    json.status literal.status
  end

  json.readings word.readings do |reading|
    json.text reading.text
    json.status reading.status
  end

  json.senses word.senses do |sense|
    json.text sense.text
    json.categories sense.categories
    json.extras sense_extras(sense)
  end
end
