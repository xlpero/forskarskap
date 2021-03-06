# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


#------------------------------------------CLEARING OLD DATA------------------------------------------
Visit.delete_all
Person.delete_all
Locker.delete_all



#-----------------------------------------------LOCKERS-----------------------------------------------

@reading = File.read("public/LOCKERS.LST").force_encoding('UTF-8')

if ! @reading.valid_encoding?
  @reading = @reading.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
  @reading.gsub(/dr/i,'med')
end

@data = @reading.split(/\n+/)

@data.each do |entry|
  Locker.create(number: entry)
end



#-----------------------------------------------PEOPLE-----------------------------------------------


@reading = File.read("public/INDEX.LST").force_encoding('UTF-8')

if ! @reading.valid_encoding?
  @reading = @reading.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
  @reading.gsub(/dr/i,'med')
end

@data = @reading.split(/\n+/)

@data.each do |entry|
  eArr = entry.split('?') 
  s = eArr.count
  # name=eArr[0...s-4] cardNbr=eArr[s-3] lockerNbr=eArr[s-2] registrationDate=eArr[s-1]


  @searchString = "https://koha-intra.ub.gu.se/cgi-bin/koha/svc/members/forskreg-lookup?cnr=" + eArr[s-3] + "&key=!kk889fr!"
  @gp = eval(Net::HTTP.get(URI(@searchString)))[:patron]
  
  @date = Date.strptime(eArr[s-1], '%m-%d-%Y')
  @locker = Locker.where(number: eArr[s-2]).first

  if @gp[:name] && @date && @locker
    Person.create(name: @gp[:name].force_encoding('UTF-8'), personnbr: @gp[:person_number], cardnbr: @gp[:card_number], registrationDate: @date, locker_id: @locker.id)
  else
    puts "PERSON ERROR: "
    eArr.each do |i|
      puts i
    end
    puts "|"
  end

  
end



#----------------------------------------VISITS----------------------------------------------


@reading = File.read("public/LOGG.LST").force_encoding('UTF-8')

if ! @reading.valid_encoding?
  @reading = @reading.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
  @reading.gsub(/dr/i,'med')
end

@data = @reading.split(/\n+/)

@data.each do |entry|
  eArr = entry.split('?') #cardnbr = eArr[0] date=eArr[1]
  
  @person = Person.where(cardnbr: eArr[0]).first
  @date = Date.strptime(eArr[1], '%m-%d-%Y')
  
  if @person && @date
    
    if @date < @person.registrationDate
      Person.update(@person.id, :registrationDate => @date)
    end
    
    
    @duplicate = Visit.where(["date = ? and person_id = ?", @date, @person.id]).take
    
    if !@duplicate
      Visit.create(date: @date, person_id: @person.id)
    end
    
  end
  

end







