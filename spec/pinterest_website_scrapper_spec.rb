require 'spec_helper'

describe PinterestWebsiteScraper do

  let(:ryansammy_web_profile) do
      PinterestWebsiteCaller.new.get_profile_page('ryansammy')
  end

  let(:helloyoga_web_profile) do
      PinterestWebsiteCaller.new.get_profile_page('Helloyoga')
  end

  let(:non_existent_web_profile) do
      PinterestWebsiteCaller.new.get_profile_page('xz')
  end

  let(:ryansammy_bmw_board) do
      PinterestWebsiteCaller.new.get_board_page('ryansammy','bmw')
  end

  let(:crystalinan_style_board) do
       PinterestWebsiteCaller.new.get_board_page('crystalinan','style')
  end

  let(:cespins_mens_clothing_board) do
      PinterestWebsiteCaller.new.get_board_page_from_url("CESPINS/men-clothing")
  end

  let(:kidsworld_board) do
      PinterestWebsiteCaller.new.get_board_page_from_url("gluecklich/kidsworld/")
  end

  let(:followben_board) do
      PinterestWebsiteCaller.new.get_board_page_from_url("jchongdesign/drinks/")
  end


  let(:ryansammy_non_existent_board) do
      PinterestWebsiteCaller.new.get_board_page('ryansammy','i_do_not_exist_board')
  end

  let(:ryansammy_followers_page) do
      PinterestWebsiteCaller.new.get_followers_page('ryansammy')
  end

  let(:maryannrizzo_web_profile) do
      PinterestWebsiteCaller.new.get_profile_page('maryannrizzo')
  end

  let(:maryannrizzo_everything_board) do
      PinterestWebsiteCaller.new.get_board_page('maryannrizzo','everything')
  end

  let(:expected_result_from_profile_page_scraping) do
    {
      "profile_name"        => "Ryan Sammy",
      "followers_count"     => "917",
      "profile_description" => "Food lover, Craft Beer Enthusiast, and BMW fanatic.",
      "boards_count"        => "83",
      "pins_count"          => "1795",
      "likes_count"         => "276",
      "followed"            => "526"
    }
  end

  let(:expected_results_from_bmw_board_scraping) do
    {
      "owner_name"      =>"Ryan Sammy",
      "board_name"      => "BMW",
      "description"     => "The cars I dream about.",
      "pins_count"      => "241",
      "followers_count" => "520"
    }
  end

  let(:expected_results_from_cespins_mens_clothing_board_scraping) do
    {
      "owner_name"      => "",
      "board_name"      => "Men Clothing",
      "description"     => "Welcome to this board and many thanks for all your contributions. Men's clothing only. Constant repins will be deleted. Pins without source links will be deleted.    carlapin50@gmail.com",
      "pins_count"      => "48976",
      "followers_count" => "24764"
    }
  end

  before(:each) do
    PinterestWebsiteCaller.any_instance.stub(:website_connection).and_return(
      Faraday.new(url: PinterestInteractionsBase::WEB_BASE_URL) do |faraday|
        faraday.request  :url_encoded
        faraday.headers['Connection'] = 'keep-alive'
        faraday.headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131 Safari/537.36'
        faraday.headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
        faraday.headers['Accept-Language'] = 'en-US,en;q=0.8,pl;q=0.6'
        faraday.headers['Referer'] = 'https://www.google.pl/'
        faraday.headers['Dnt'] = '1'
        faraday.use FaradayMiddleware::FollowRedirects
        faraday.use FaradayMiddleware::FollowRedirects, limit: 5
        faraday.adapter  :net_http
      end
    )
  end

  describe '#scrape_data_for_profile_page' do
    it 'gets the data from page' do
        expect(subject.scrape_data_for_profile_page(ryansammy_web_profile)).
          to eq(expected_result_from_profile_page_scraping)
    end

    it 'returns nil when trying to get non existent profile_page' do
        expect(subject.scrape_data_for_profile_page(non_existent_web_profile)).to be(nil)
    end

    it 'returns list of all boards for profile page' do
      expect(subject.get_pinterest_boards(maryannrizzo_web_profile).size).
          to eq(273)
    end

    it 'returns list of all boards for profile page for helloyoga' do
        expect(subject.get_pinterest_boards(helloyoga_web_profile).size).
          to eq(10)
    end


    it 'returns nil if boards are being fetched for non existent profile page' do
        expect(subject.get_pinterest_boards(non_existent_web_profile)).
          to be(nil)
    end

  end

  describe '#get media files from board' do
    it 'fetches media files from pinterest board' do
        result = subject.get_latest_pictures_from_board(followben_board)
        expect(result).not_to be(nil)
    end
  end

  describe 'get profile picture' do
    it 'returns link to profile picture' do
      result = subject.get_profile_picture('ryansammy')
      expect(result).to eq('http://media-cache-ec0.pinimg.com/avatars/ryansammy_1365793703_140.jpg')
    end
  end

  describe "#get boards data" do
    it "gets data for given pinterest board" do
        expect(subject.get_board_information(ryansammy_bmw_board)).
          to eq(expected_results_from_bmw_board_scraping)
    end

    it "gets data for given pinterest board with large number of followers" do
        expect(subject.get_board_information(cespins_mens_clothing_board)).
          to eq(expected_results_from_cespins_mens_clothing_board_scraping)
    end

    it 'returns nil if non existing board name is used for fetching board information' do
        expect(subject.get_board_information(ryansammy_non_existent_board)).
          to be(nil)
    end

    it "gets data for given pinterest board with large number of followers" do
        result = subject.get_board_information(crystalinan_style_board)
        expect(result).not_to be(nil)
    end
  end

  describe 'get image info' do
    it 'returns correct information with likes and repins for media file' do
      result = subject.get_image_info('pin/35747390766522571')
      expect(result['result']).to eq('ok')
      expect(result['likes']).to eq('160')
      expect(result['repins']).to eq('1365')
      expect(result['comments']).to eq('3')
    end

    it 'returns error when media file does not exist' do
      result = subject.get_image_info('pin/35747390767642206')
      expect(result['result']).to eq('error')
    end
  end

  describe "#get followers data" do
    xit "gets followers data meeting given criteria for profile name" do
      expected_result = [
        {
          "profile_name" => "Ognyan Tortorochev",
          "url" => "/tortorochev/",
          "pins" => "54707",
          "followers" => "188590",
          "info_and_links"=>
          {
            "email" => "art_ok@live.com",
            "website" => "",
            "location" => "Bratislava",
            "facebook" => "http://www.facebook.com/thousands.pictures.5",
            "twitter" => "http://twitter.com/Tortorochev"
          }
        }
      ]
        result = subject.get_followers(ryansammy_followers_page, 100000, 200)
        expect(result).to eq(expected_result)
    end

    it 'should not process more followers then passed limit' do
        result = subject.get_followers(ryansammy_followers_page, 1000, 20)
        expect(result.size).to eq(7)
    end

    it 'should start processing from second page of followers list' do
        result = subject.get_followers_for_cache(ryansammy_followers_page, 10000, 200, 2)
        expect(result['followers_list'].size).to eq(17)
    end

    it 'should provide all links and infos' do
      expected_result = {
        "email" => "",
        "website" => "www.ryansammy.com",
        "location" => "Berkeley, CA",
        "facebook" => "https://www.facebook.com/ryan.sammy",
        "twitter" => "",
        "followers_count" => "917",
        "pins" => "1795",
        "profile_name" => "Ryan Sammy"
      }
        result = subject.get_info_and_links('ryansammy')
        expect(result).to eq(expected_result)
    end

  end
end
