class Protein
  include Mongoid::Document
  belongs_to                :transcript
  embeds_many               :positions, :cascade_callbacks => true

  field :protein_id,        :type => String
  field :name,              :type => String
  field :external_ids,      :type => Hash
  field :tissues,           :type => Array
end
