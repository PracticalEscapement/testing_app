class User < ApplicationRecord

  has_secure_password
  before_save :set_username
  before_destroy :nullify_manager_id

  validates :first_name, :last_name, :title, :password_digest, presence: true
  has_many :direct_reports, class_name: "User", foreign_key: :manager_id
  belongs_to :manager, class_name: "User", optional: true
  validates :password, length: { minimum: 6 }, unless: Proc.new { |a| a.password.blank? }
  validate :ensure_manager_id_integrity

  def name
    [first_name, last_name].join(' ')
  end

  def set_username
    self.username = [first_name[0], last_name].join('.').downcase
  end

  def nullify_manager_id
    self.direct_reports.find_each do |direct_report|
      direct_report.update_column(:manager_id, nil)
    end
  end

  def token
    JWT.encode({user_id: id}, Rails.application.secrets.secret_key_base, "HS256")
  end

  def ensure_manager_id_integrity
    self.direct_reports.find_each do |direct_report|
      if self.manager_id == direct_report.id
        raise(ActiveRecord::RecordInvalid)
      end
      direct_report.direct_reports.find_each do |second_level_direct_report|
        if self.manager_id == second_level_direct_report.id
          raise(ActiveRecord::RecordInvalid)
        end
      end
    end
  end

  def as_json(options = {})
    h = super(options)
    h["name"] = name
    h
  end

  
end
