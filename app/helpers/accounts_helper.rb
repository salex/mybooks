module AccountsHelper
  def icon(klass, text = '')
    icon_tag = tag.i(class: klass)
    text_tag = tag.span ' ' + text
    text ? tag.span(icon_tag + text_tag) : icon_tag
  end

  def text_field_with_border(form,attribute)
    form.text_field(attribute, class:"border-1 mx-2 m-2")
  end

  def acct_list(root,p=0)
    if params[:tree].present?
      return acct_tree(root)
    end
    html = content_tag(:div, class: 'pl-row') {
      ul_contents = ""
      # ul_contents << content_tag(:div, link_to(root.name,account_checkbooks_path(guid:root.guid)), class:"col-acct p#{p}")
      ul_contents << content_tag(:div, link_to(root.name,account_path(root)), class:"col-acct p#{p}")

      ul_contents << content_tag(:div,node_balance(root),class:'pl-col-11')
      p +=1
      root.children.each do |child|
        ul_contents << acct_list(child,p)
      end
      p -= 1
      ul_contents.html_safe
    }.html_safe
  end

  def summary_list(root,p=0)
    # if params[:tree].present?
    #   return acct_tree(root)
    # end
    html = content_tag(:div, class: "ml-#{root.level}") {
      ul_contents = ""
      ul_contents << content_tag(:div, link_to(root.name,account_path(root)), 
        class:"blue-link inline-block ml-#{root.level}")

      ul_contents << content_tag(:div,node_balance(root),
        class:'inline-block text-right float-right')
      root.children.each do |child|
        ul_contents << summary_list(child)
      end
      ul_contents.html_safe
    }.html_safe
  end

  # replaced by acct_tree_ids in Account model
  # def acct_tree(root,p=0)
  #   html = content_tag(:div, class: 'pl-row') {
  #     ul_contents = ""
  #     ul_contents << content_tag(:div, root.name, class:"col-acct p#{p}")
  #     p +=1
  #     root.children.each do |child|
  #       ul_contents << acct_tree(child,p)
  #     end
  #     p -= 1
  #     ul_contents.html_safe
  #   }.html_safe
  # end

  def node_balance(acct)
    b = acct.family_balance
    b.zero? ? "" : to_money(b,'$')
  end

  def report_select_options(account_id,url,other=nil)
    options = []
    if account_id.present?
      options << ['Custom Dates',"#{url}?fromto=1&account=#{account_id}"]
    else
      options << ['Custom Dates',"#{url}?fromto=1"]
    end

    date = Date.today.beginning_of_month
    12.times do |i|
      this_url = url+"?date=#{date.to_s}"
      if account_id.present?
        this_url = this_url + "&account=#{account_id}"
      end
      this_url = this_url + other if other.present?
      options << [date.to_formatted_s(:month_and_year),this_url]
      date = date.last_month
    end
    options
  end


end
