module NewsTags
    include Radiant::Taggable

  desc %{
    Gets scrolltext with active news.

    *Usage:*
    <r:news:marquee [behavior="scroll"] [direction="left"] [loop="true"] [scrollamount="1"] [scrolldelay="2"] />
  }
  tag 'newsMarquee' do |tag|
    html = ''
    currentnews.each do |news|
      html += '<b>' + news.headline+'</b>: ' + news.leadtext + " "
    end
    
    content_tag(:marquee, html, 
      :behavior => tag.attr['behavior='],
      :direction => tag.attr['direction'],
      :loop => tag.attr['loop'],
      :scrollamount  => tag.attr['scrollamount'],
      :scrolldelay  => tag.attr['scrolldelay'])
  end

  tag 'news' do |tag|
    tag.expand
  end

  desc %{
    Allow to iterate over news which are active today.
        
  }
  tag 'news:current' do |tag|
    result = []
    options = {}

    #process options
    options.merge!({:limit => tag.attr["limit"].to_i}) if tag.attr["limit"]
    options.merge!({:offset => tag.attr["offset"].to_i}) if tag.attr["offset"]
    
    #process categories
    category_arr = tag.attr['category'].split(",").map {|x| x.strip} if tag.attr['category']
    options.merge!({:categories => category_arr})if category_arr
    
    #process tags
    tag_arr = tag.attr['tag'].split(",").map {|x| x.strip} if tag.attr['tag']
    options.merge!({:tags => tag_arr})if tag_arr
        
    news = currentnews(options)
    news.each do |x|
      tag.locals.news = x
      result << tag.expand
    end
    result
  end

  desc %{
    Returns headline of current news
  }
  tag 'news:headline' do |tag|
    tag.locals.news.headline
  end

  desc %{
    Returns leadtext of current news
  }
  tag 'news:leadtext' do |tag|
    tag.locals.news.leadtext
  end

  desc %{
    Returns text of current news
  }
  tag 'news:text' do |tag|
    tag.locals.news.text
  end

  def currentnews(parameter)
    curr_date = Time.now
    str_conditions = 'start <=  ? and (stop is null or stop >= ?)'
    arr_parameter = [curr_date, curr_date]
    arr_table_join = []

    if parameter[:categories] #Array of String category ex ['Category 1','Category 2'] 
      str_conditions += ' AND news_categories.name in (?)'
      arr_parameter += [parameter[:categories]]
      arr_table_join += ['news_categories']
    end
    
    if parameter[:tags] #Array of String tag ex ['Tag 1', 'Tag 2'] 
      str_conditions += ' AND news_tags.name in (?)'
      arr_parameter += [parameter[:tags]]
      arr_table_join += ['news_tags']
    end
    
    find_parameters = {:conditions => [str_conditions] + arr_parameter, :order => 'start DESC, news_entries.id DESC'}    
    find_parameters.merge!({:include => arr_table_join}) if arr_table_join
    find_parameters.merge!({:limit => parameter[:limit]}) if parameter[:limit]
    find_parameters.merge!({:offset => parameter[:offset]}) if parameter[:offset]
    NewsEntry.find(:all, find_parameters)
  end
end
