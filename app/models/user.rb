class User < ApplicationRecord
  validates_presence_of :name, :email, :token, :uid
  validates_uniqueness_of :uid, case_sensitive: false
  validates :email,
            uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }

  has_many :meals, dependent: :destroy

  has_many :meal_dishes, through: :meals
  has_many :dishes, through: :meal_dishes

  has_many :dish_foods, through: :dishes
  has_many :foods, through: :dish_foods

  has_many :meal_ingredients, through: :meals
  has_many :ingredients, through: :meal_ingredients

  def ratings_needed
    12 - meals.where.not(gut_feeling: nil).count
  end

  def worst_ingredients_data
    ingredients.uniq.map do |ingredient|
      {
        name: ingredient.name,
        avg_gut_feeling: ingredient.average_gut_feeling(self)
      }
    end.sort_by { |ingredient_hash| ingredient_hash[:avg_gut_feeling]}[0..24]
  end

  def best_ingredients_data
    ingredients.uniq.map do |ingredient|
      {
        name: ingredient.name,
        avg_gut_feeling: ingredient.average_gut_feeling(self)
      }
    end.sort_by { |ingredient_hash| -ingredient_hash[:avg_gut_feeling]}[0..24]
  end

end
