
module ButtonHelper
  def btn_lg
    "ml-2 rounded-xl py-5 px-7 bg-gray-200 inline-block font-medium "
  end

  def btn_md
    "ml-2 rounded-lg py-3 px-5 bg-gray-200 inline-block font-medium "
  end

  def btn_sm
    "ml-2 rounded-md py-1 px-3 bg-gray-200 inline-block font-medium "
  end
  
  def btn_submit
    "mt-2 rounded-md py-4 px-6 bg-blue-700 text-white hover:bg-blue-600 inline-block font-medium"
  end

  def btn_sm_blue
    btn_sm + "bg-blue-200 hover:bg-blue-300 "
  end

  def btn_sm_red
    btn_sm + "bg-red-700 hover:bg-red-800 text-white "
  end

  def btn_sm_green
    btn_sm + "bg-green-200 hover:bg-green-300 "
  end

  def btn_lg_green
    btn_lg + "bg-green-500 hover:bg-green-300 "
  end
  

  def icon(klass, text = nil)
    icon_tag = tag.i(class: klass)
    text_tag = tag.span ' ' + text
    text ? tag.span(icon_tag + text_tag) : icon_tag
  end

  def btn
   "py-1 px-2 text-black hover:text-white rounded font-lg font-bold "
  end

  def btnInfo
   btn + "bg-blue-400 text-blue-link hover:text-blue-100 "
  end

  def btnWarn
   btn + "bg-orange-300 hover:text-yellow-200 "
  end

  def btnGreen
   btn + "bg-green-500 hover:text-green-100 "
  end

  def btnDanger
   btn + "bg-red-500 hover:text-red-200 "
  end

  def btnSuccess
   btn + "bg-success hover:bg-green-700 "
  end

  def btnSecondary
   btn + "bg-secondary "
  end

  def btnSubmit
    btnGreen + "m-1 border-2"
  end

  def blueBox
    "box-border box-content m-3 p-4 bg-blue-400 border-blue-200 border-2 text-black"
  end


end
