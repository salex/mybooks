module EntriesHelper
  def from_period_select(date_id:nil)
    today = Date.today
    bom = today.beginning_of_month
    bopm = bom - 1.month
    boq = today.beginning_of_quarter
    bopq = boq - 3.months
    boy = today.beginning_of_year
    bopy = boy - 1.year
    qtr1 = boy
    qtr2 = boy + 3.months
    qtr3 = boy + 6.months
    qtr4 = boy + 9.months
    all = Date.new(2014,1,1)
    options = [
      ['Select From Period',nil],
      ['Beginning of Month',bom.to_s],
      ['Beginning of Quarter',boq.to_s],
      ['Beginning of Year',boy.to_s],
      ['Beginning of Prev Month',bopm.to_s],
      ['Beginning of Prev Quarter',bopq.to_s],
      ['Beginning of Prev Year',bopy.to_s],
      ['Quarter 1',qtr1.to_s],
      ['Quarter 2',qtr2.to_s],
      ['Quarter 3',qtr3.to_s],
      ['Quarter 4',qtr4.to_s],

      ['All',all.to_s]

    ]
    date = bom
    6.times do |i|
      options << [date.to_formatted_s(:month_and_year),date.to_s]
      date = date.last_month
    end
    date = "2014-01-01".to_date 
    while date < today.beginning_of_year do 
      options << [date.year.to_s+ " Accounting Year",date.to_s]
      date = date + 1.year 
    end


    content_tag(:select,options_for_select(options),
      class:'w-full rounded-none  px-2', id: :from_select,
      data:{
        dateRange_target:'fromOptions',
        action:'change->dateRange#fromOption',
        date_id:date_id
      })
  end

  def to_period_select(date_id:nil)
    today = Date.today
    bom = today.beginning_of_month
    eom = today.end_of_month
    eopm = (eom - 1.month).end_of_month
    eoq = today.end_of_quarter
    eopq = eoq - 3.months
    eoy = today.end_of_year
    eopy = eoy - 1.year
    boy = today.beginning_of_year
    qtr1 = boy.end_of_quarter
    qtr2 = (boy + 3.months).end_of_quarter
    qtr3 = (boy + 6.months).end_of_quarter
    qtr4 = (boy + 9.months).end_of_quarter

    options = [
      ['Select To Period',nil],
      ['End of Month',eom.to_s],
      ['End of Quarter',eoq.to_s],
      ['End of Year',eoy.to_s],
      ['End of Prev Month',eopm.to_s],
      ['End of Prev Quarter',eopq.to_s],
      ['End of Prev Year',eopy.to_s],
      ['End of Quarter 1',qtr1.to_s],
      ['End of Quarter 2',qtr2.to_s],
      ['End of Quarter 3',qtr3.to_s],
      ['End of Quarter 4',qtr4.to_s],

      ['Current Date',today.to_s]

    ]
    date = bom
    6.times do |i|
      options << [date.end_of_month.to_formatted_s(:month_and_year),date.end_of_month.to_s]
      date = date.last_month
    end
    date = "2014-12-31".to_date 
    while date < today.beginning_of_year do 
      options << [date.year.to_s+ " Accounting Year",date.to_s]
      date = date + 1.year 
    end


    content_tag(:select,options_for_select(options),
      class:'w-full rounded-none  px-2',id: :to_select,
        data:{
          dateRange_target:'toOptions',
          action:'change->dateRange#toOption',
          date_id:date_id
        })
  end


end
