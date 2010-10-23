class Array
  def mean
    sum = self.inject(0) { |b,i| b+i }
    sum / size
  end
  
  def variance
    n = 0
    mean = 0.0
    s = 0.0
    self.each do |x|
      n = n + 1
      delta = x - mean
      mean = mean + (delta / n)
      s = s + delta * (x - mean)
    end
    s / n
  end

  def standard_deviation
    Math.sqrt(variance)
  end
end
