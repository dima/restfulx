<% counter = 0 -%>
<% controller_modules.each_with_index do |mod, i| -%>
<%= "  " * i %>module <%= mod %>
<% counter = i -%>
<% end -%>
<% counter = counter == 0 ? 0 : (counter + 1) -%>
<%= "  " * counter %>class <%= controller_class_name %> < Application
<%= "  " * counter %>  provides :xml, :fxml

<%= "  " * counter %>  def index
<%= "  " * counter %>    @<%= plural_model %> = <%= model_class_name %>.find(:all)
<%= "  " * counter %>    display @<%= plural_model %>
<%= "  " * counter %>  end

<%= "  " * counter %>  def show
<%= "  " * counter %>    @<%= singular_model %> = <%= model_class_name %>.find_by_id(params[:id])
<%= "  " * counter %>    raise NotFound unless @<%= singular_model %>
<%= "  " * counter %>    display @<%= singular_model %>
<%= "  " * counter %>  end

<%= "  " * counter %>  def create
<%= "  " * counter %>    @<%= singular_model %> = <%= model_class_name %>.new(params[:<%= singular_model %>])
<%= "  " * counter %>    if @<%= singular_model %>.save
<%= "  " * counter %>      display @<%= singular_model %>
<%= "  " * counter %>    else
<%= "  " * counter %>      display @<%= singular_model %>.errors
<%= "  " * counter %>    end
<%= "  " * counter %>  end

<%= "  " * counter %>  def update
<%= "  " * counter %>    @<%= singular_model %> = <%= model_class_name %>.find_by_id(params[:id])
<%= "  " * counter %>    raise NotFound unless @<%= singular_model %>
<%= "  " * counter %>    if @<%= singular_model %>.update_attributes(params[:<%= singular_model %>])
<%= "  " * counter %>      display @<%= singular_model %>
<%= "  " * counter %>    else
<%= "  " * counter %>      display @<%= singular_model %>.errors
<%= "  " * counter %>    end
<%= "  " * counter %>  end

<%= "  " * counter %>  def destroy
<%= "  " * counter %>    @<%= singular_model %> = <%= model_class_name %>.find_by_id(params[:id])
<%= "  " * counter %>    raise NotFound unless @<%= singular_model %>
<%= "  " * counter %>    if @<%= singular_model %>.destroy
<%= "  " * counter %>      display @<%= singular_model %>
<%= "  " * counter %>    else
<%= "  " * counter %>      display @<%= singular_model %>.errors
<%= "  " * counter %>    end
<%= "  " * counter %>  end

<%= "  " * counter %>end
<% counter = counter == 0 ? 0 : (counter - 1) -%>
<% controller_modules.reverse.each_with_index do |mod, i| -%>
<%= "  " * counter %>end # <%= mod %>
<% counter = counter - 1 -%>
<% end -%>
