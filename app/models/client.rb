class Client < ActiveRecord::Base
  VERTICALS = %w(Self-Storage Apartments Assisted-Living)
  
  attr_accessible :name, :street_address_1, :street_address_2, :city, :state, :postal_code, :country, :fax, :email, :vertical, :locations_attributes, :urn

  has_many :locations
  
  validates :name, uniqueness: true, presence: true
  validates :vertical, inclusion: { in: VERTICALS, message: "%{value} is not a valid vertical" }
  accepts_nested_attributes_for :locations,
    allow_destroy: true,
    reject_if: lambda { |attrs| attrs[:name].blank? }

  after_save :post_webhook
  after_create :set_urn

  def record_type
    "g5-c"
  end

  def hashed_id
    "#{self.created_at.to_i}#{self.id}".to_i.to_s(36)
  end

  def to_param
    self.urn
  end

  private

  def set_urn
    update_attributes(urn: "#{record_type}-#{hashed_id}-#{name.parameterize}")
  end

  def post_webhook
    url = ENV["G5_CONFIGURATOR_WEBHOOK_URL"]
    if url
      begin
        Webhook.post(url)
      rescue ArgumentError => e
        logger.error e
      end
    end
  end
end
