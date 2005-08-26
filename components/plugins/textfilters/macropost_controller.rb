class Plugins::Textfilters::MacroPostController < TextFilterPlugin
  def self.display_name
    "MacroPost"
  end

  def self.description
    "Macro expansion meta-filter (post-markup)"
  end

  def filtertext
    text = params[:text]
    filterparams = params[:filterparams]
    
    macros = TextFilter.available_filter_types['macropost']
    text = macros.inject(text) do |text,macro|
      render_component_as_string(:controller => macro.controller_path,
        :action => 'filtertext', :params => {:text => text, :filterparams => filterparams})
    end

    render :text => text
  end
end
