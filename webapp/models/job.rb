require 'csv'

class Job
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to  :account
  embeds_many :binds,   cascade_callbacks: true
  has_many    :genes,   dependent: :delete, autosave: true

  attr_accessor :query

  field :complete,      type: Boolean, default: false
  field :description,   type: String
  field :notify,        type: Boolean, default: false
  field :time,          type: Integer

  validates_presence_of :query, :if => :query_required
  validates_presence_of :complete
  validates_presence_of :notify
  validates_presence_of :description
  validates_length_of   :description, :within => 5..256

  index({ created_at: 1 }, { background: false })

  def self.find_by_id(id)
    find(id) rescue nil
  end

  def to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << %w[species gene_id gene_name transcript_id transcript_name] + self.bind_proteins.keys
      genes.each do |gene|
        gene.transcripts.each do |trans|
          csv << [gene.species, gene.converted_id, gene.name, trans.converted_id, trans.name] + trans.matches.map { |x| x ? 'x' : '' }
        end
      end
    end
  end

  def dataset_json
    dataset = [['Proteins', 'Occurrences']]
    bind_proteins.each { |prot, values| dataset << [prot, values['count']] }
    return dataset.to_json
  end

  private
  def query_required
    return !self.complete
  end
end
