require 'fileutils'
require 'csv'

class PokemonCsv
  class RecordInvalid < StandardError; end
  class RecordNotFound < StandardError; end

  attr_accessor :number, :name, :type1,
                  :type2, :total, :hp, :attack,
                  :defense, :sp_atk, :sp_def,
                  :speed, :generation, :legendary,
                  :error_messages

  DATABASE_FILENAME = Rails.root.join('db', 'database.csv')
  TMP_DATABASE_FILENAME = Rails.root.join('db', 'database_tmp.csv')

  def initialize(params = {})
    assign_params(params)
    # set legendary as false by default
    self.legendary = false if self.legendary.blank?
  end

  def valid?(create = true)
    # validates presence of number, name, type1, total, hp, attack, defense, sp_atk, sp_def, speed, generation
    self.error_messages = []
    valid = true
    # if none of these fields is blank, is valid
    [:number, :name, :type1, :total, :hp, :attack, :defense, :sp_atk, :sp_def, :speed, :generation].each do |field_name|
      field_is_valid = !self.send(field_name).blank?
      valid = valid && field_is_valid
      self.error_messages.push("#{field_name} can not be blank") unless field_is_valid
    end

    # validates numericality of number, total, hp, attack, defense, sp_atk, sp_def, speed and generation
    [:number, :total, :hp, :attack, :defense, :sp_atk, :sp_def, :speed, :generation].each do |field_name|
      field_is_valid = self.send(field_name).is_a? Numeric
      valid = valid && field_is_valid
      self.error_messages.push("#{field_name} must be a number") unless field_is_valid
    end

    # validate uniqueness of name (it is our primary key). Do it only on create!
    valid = valid && is_name_unique?(self.name) if create

    valid
  end

  def csv_representation
    fields = [:number, :name, :type1,
      :type2, :total, :hp, :attack,
      :defense, :sp_atk, :sp_def,
      :speed, :generation].map{|field_name| send(field_name)}
    # set false or true as False or True because the rest of the file has them like this
    fields.push(self.legendary ? 'True' : 'False')
    fields.join(',')
  end

  def api_response
    {
      number: self.number,
      name: self.name,
      type1: self.type1,
      type2: self.type2,
      total: self.total,
      hp: self.hp,
      attack: self.attack,
      defense: self.defense,
      sp_atk: self.sp_atk,
      sp_def: self.sp_def,
      speed: self.speed,
      generation: self.generation,
      legendary: self.legendary
    }
  end

  # accepted method for updating a file is to create a tmp file
  # and write to it, edit it and then copy to the previous file
  def update(params)
    # assign incoming params to this object
    assign_params(params)

    raise RecordInvalid.new(self.error_messages.join(',')) unless self.valid?(false)

    File.open(TMP_DATABASE_FILENAME, 'w') do |out_line|
      # write headers
      out_line.puts(CSV.open(DATABASE_FILENAME, &:readline).join(','))
      # process file
      CSV.foreach(DATABASE_FILENAME, headers: true, converters: %i[numeric]) do |line|
        out_line.puts(line['Name'] == name ? self.csv_representation : line.to_s.strip)
      end
    end

    FileUtils.mv(TMP_DATABASE_FILENAME, DATABASE_FILENAME)
    true
  end

  def destroy
    File.open(TMP_DATABASE_FILENAME, 'w') do |out_line|
      # write headers
      out_line.puts(CSV.open(DATABASE_FILENAME, &:readline).join(','))
      # process file
      CSV.foreach(DATABASE_FILENAME, headers: true, converters: %i[numeric]) do |line|
        out_line.puts(line.to_s.strip) unless line['Name'] == self.name
      end
    end

    FileUtils.mv(TMP_DATABASE_FILENAME, DATABASE_FILENAME)
    true
  end

  # Eigenclass methods
  class << self
    def from_csv(csv_row)
      new(
        number:   csv_row['#'],
        name:     csv_row['Name'],
        type1:    csv_row['Type 1'],
        type2:   csv_row['Type 2'],
        total:   csv_row['Total'],
        hp:   csv_row['HP'],
        attack:   csv_row['Attack'],
        defense:   csv_row['Defense'],
        sp_atk:   csv_row['Sp. Atk'],
        sp_def:   csv_row['Sp. Def'],
        speed:   csv_row['Speed'],
        generation:   csv_row['Generation'],
        legendary:   csv_row['Legendary'] == 'True'
      )
    end

    def create(params)
      pokemon = new(params)

      raise RecordInvalid.new(pokemon.error_messages.join(',')) unless pokemon.valid?

      open(DATABASE_FILENAME, 'a') {|f| f.puts pokemon.csv_representation}

      pokemon
    end

    def find_by_name(name)
      # the unique identifier must be the name, as multiple pokemons share
      # the same number (i.e: VenusaurMega Venusaur share the number 3)
      CSV.foreach(DATABASE_FILENAME, headers: true, converters: %i[numeric]) do |line|
        return from_csv(line) if line['Name'] == name
      end

      raise RecordNotFound.new('Record could not be found')
    end

    def page(page = nil, per_page = nil)
      page = (page || 0).to_i
      per_page = (per_page || 20).to_i
      start_of_page = page * per_page
      end_of_page   = (page + 1) * per_page
      paged_results = []
      CSV.foreach(DATABASE_FILENAME, headers: true, converters: %i[numeric]).with_index do |line, index|
        return paged_results if index > (end_of_page - 1)
        paged_results.push(from_csv(line)) if index >= start_of_page
      end

      paged_results
    end
  end

  private
  def is_name_unique?(name)
    CSV.foreach(DATABASE_FILENAME, headers: true, converters: %i[numeric]) do |line|
      if line['Name'] == name
        self.error_messages.push('The name must be unique')
        return false
      end
    end

    true
  end

  def assign_params(params = {})
    params.each {|key, value| self.send("#{key}=", value)  if self.respond_to?("#{key}=")}
  end
end