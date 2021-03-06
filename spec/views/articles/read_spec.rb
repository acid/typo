require 'spec_helper'

with_each_theme do |theme, view_path|
  describe "#{view_path}/articles/read" do
    before(:each) do
      @controller.view_paths.unshift(view_path) if theme
      # we do not want to test article links and such
      ActionView::Base.class_eval do
        def article_links(article)
          ""
        end
        alias :category_links :article_links
        alias :tag_links :article_links
      end
    end

    context "applying text filters" do
      before(:each) do
        @controller.action_name = "redirect"
        assign(:article, contents('article1'))
        render :file => "articles/read"
      end

      it "should not have too many paragraph marks around body" do
        rendered.should have_selector("p", :content => "body")
        rendered.should_not have_selector("p>p", :content => "body")
      end

      it "should not have too many paragraph marks around extended contents" do
        rendered.should have_selector("p", :content => "extended content")
        rendered.should_not have_selector("p>p", :content => "extended content")
      end
    end

    context "formatting comments" do
      before(:each) do
        Blog.default.comment_text_filter = 'textile'
        @controller.action_name = "read"
        assign(:article, contents('article1'))
        render :file => "articles/read"
      end

      it "should not have too many paragraph marks around comment contents" do
        rendered.should have_selector("p>em", :content => "italic")
        rendered.should have_selector("p>strong", :content => "bold")
        rendered.should_not have_selector("p>p>em", :content => "italic")
      end
    end

    context "formatting comments with bare links" do
      before(:each) do
        Blog.default.comment_text_filter = 'textile'
        @controller.action_name = "read"
        assign(:article, contents('article3'))
        render :file => "articles/read"
      end

      it "should automatically add links" do
	rendered.should have_selector("a", :href => "mailto:foo@bar.com",
				 :content => "foo@bar.com")
        rendered.should have_selector("a", :href=>"http://www.bar.com",
				 :content => "http://www.bar.com")
      end
    end
  end
end

