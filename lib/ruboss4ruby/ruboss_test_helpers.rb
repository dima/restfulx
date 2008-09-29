module RubossTestHelpers

  # Use this to test xml or fxml responses in unit tests.  For example,
  # set_response_to user.to_fxml
  # assert_xml_select 'user name', 'quentin'
  def set_response_to(response, content_type = 'xml')
    @response = MockResponse.new(response, content_type)
  end
  
  # Make xml functional testing work.
  # From http://weblog.jamisbuck.org/2007/1/4/assert_xml_select
  def xml_document
    @xml_document ||= HTML::Document.new(@response.body, false, true)
  end  
  
  def assert_xml_select(*args, &block)
    @html_document = xml_document
    assert_select(*args, &block)
  end   
  
end

class MockResponse
  attr_reader :body, :content_type
    
  def initialize(body, content_type = 'xml')
    @body = body
    @content_type = content_type
  end
  
end