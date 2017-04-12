module FactoryGirlPreloaderHelper
  def load_all_resources
    FactoryGirl.create(:water)
    FactoryGirl.create(:food)
    FactoryGirl.create(:medication)
    FactoryGirl.create(:ammunition)
  end
end