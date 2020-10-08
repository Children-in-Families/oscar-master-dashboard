class ReferralSource < ActiveRecord::Base
  REFERRAL_SOURCES = ['ក្រសួង សអយ/មន្ទីរ សអយ', 'អង្គការមិនមែនរដ្ឋាភិបាល', 'មន្ទីរពេទ្យ', 'នគរបាល', 'តុលាការ/ប្រព័ន្ធយុត្តិធម៌', 'រកឃើញនៅតាមទីសាធារណៈ', 'ស្ថាប័នរដ្ឋ', 'មណ្ឌលថែទាំបណ្ដោះអាសន្ន', 'ទូរស័ព្ទទាន់ហេតុការណ៍', 'មកដោយខ្លួនឯង', 'គ្រួសារ', 'មិត្តភក្ដិ', 'អាជ្ញាធរដែនដី', 'ផ្សេងៗ', 'សហគមន៍', 'ព្រះវិហារ', 'MoSVY External System'].freeze
  has_paper_trail

  scope :parent_categories,       ->        { where(name: REFERRAL_SOURCES) }
end
