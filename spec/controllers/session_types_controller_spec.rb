require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SessionTypesController do

  def mock_session_type(stubs={})
    @mock_session_type ||= mock_model(SessionType, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all session_types as @session_types" do
      SessionType.should_receive(:find).with(:all).and_return([mock_session_type])
      get :index
      assigns[:session_types].should == [mock_session_type]
    end

    describe "with mime type of xml" do
  
      it "should render all session_types as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        SessionType.should_receive(:find).with(:all).and_return(session_types = mock("Array of SessionTypes"))
        session_types.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested session_type as @session_type" do
      SessionType.should_receive(:find).with("37").and_return(mock_session_type)
      get :show, :id => "37"
      assigns[:session_type].should equal(mock_session_type)
    end
    
    describe "with mime type of xml" do

      it "should render the requested session_type as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        SessionType.should_receive(:find).with("37").and_return(mock_session_type)
        mock_session_type.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new session_type as @session_type" do
      SessionType.should_receive(:new).and_return(mock_session_type)
      get :new
      assigns[:session_type].should equal(mock_session_type)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested session_type as @session_type" do
      SessionType.should_receive(:find).with("37").and_return(mock_session_type)
      get :edit, :id => "37"
      assigns[:session_type].should equal(mock_session_type)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created session_type as @session_type" do
        SessionType.should_receive(:new).with({'these' => 'params'}).and_return(mock_session_type(:save => true))
        post :create, :session_type => {:these => 'params'}
        assigns(:session_type).should equal(mock_session_type)
      end

      it "should redirect to the created session_type" do
        SessionType.stub!(:new).and_return(mock_session_type(:save => true))
        post :create, :session_type => {}
        response.should redirect_to(session_type_url(mock_session_type))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved session_type as @session_type" do
        SessionType.stub!(:new).with({'these' => 'params'}).and_return(mock_session_type(:save => false))
        post :create, :session_type => {:these => 'params'}
        assigns(:session_type).should equal(mock_session_type)
      end

      it "should re-render the 'new' template" do
        SessionType.stub!(:new).and_return(mock_session_type(:save => false))
        post :create, :session_type => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested session_type" do
        SessionType.should_receive(:find).with("37").and_return(mock_session_type)
        mock_session_type.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :session_type => {:these => 'params'}
      end

      it "should expose the requested session_type as @session_type" do
        SessionType.stub!(:find).and_return(mock_session_type(:update_attributes => true))
        put :update, :id => "1"
        assigns(:session_type).should equal(mock_session_type)
      end

      it "should redirect to the session_type" do
        SessionType.stub!(:find).and_return(mock_session_type(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(session_type_url(mock_session_type))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested session_type" do
        SessionType.should_receive(:find).with("37").and_return(mock_session_type)
        mock_session_type.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :session_type => {:these => 'params'}
      end

      it "should expose the session_type as @session_type" do
        SessionType.stub!(:find).and_return(mock_session_type(:update_attributes => false))
        put :update, :id => "1"
        assigns(:session_type).should equal(mock_session_type)
      end

      it "should re-render the 'edit' template" do
        SessionType.stub!(:find).and_return(mock_session_type(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested session_type" do
      SessionType.should_receive(:find).with("37").and_return(mock_session_type)
      mock_session_type.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the session_types list" do
      SessionType.stub!(:find).and_return(mock_session_type(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(session_types_url)
    end

  end

end
