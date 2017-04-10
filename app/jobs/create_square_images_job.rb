class CreateSquareImagesJob < ActiveJob::Base

  def perform(image)
    image.image.reprocess_without_delay!(:square, :square_2x)
  end
end

