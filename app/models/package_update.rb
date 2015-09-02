class PackageUpdate < ActiveRecord::Base
  belongs_to :node
  belongs_to :package

  scope :not_applied, ->() { where(applied: false) }
  scope :security, ->() { includes(:package).where(packages: {security: true}) }
  scope :not_security, ->() { includes(:package).where(packages: {security: false}) }

  def self.by_package(relation)
    ret = {}
    relation.each do |update|
      ret[update.package] ||= []
      ret[update.package] << update
    end
    Hash[ret.sort_by { |package, updates| 1 - updates.size }]
  end
end
