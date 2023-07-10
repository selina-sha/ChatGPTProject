class User < ApplicationRecord
    has_many :ratings
    validates :description, presence: true
    validates :career, presence: true, length: { minimum: 10 }
end
