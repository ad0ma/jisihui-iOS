
import UIKit

//@IBDesignable
class RatingBar: UIView {
    
    @IBInspectable var rating: CGFloat = 0{//当前数值
        didSet{
            if 0 > rating {rating = 0}
        }
    }
    @IBInspectable var ratingMax: CGFloat = 5//总数值,必须为numStars的倍数
    @IBInspectable var numStars: Int = 5 //星星总数
    @IBInspectable var canAnimation: Bool = true//是否开启动画模式
    @IBInspectable var animationTimeInterval: TimeInterval = 0.25//动画时间
    @IBInspectable var incomplete:Bool = false//评分时是否允许不是整颗星星
    @IBInspectable var isIndicator:Bool = true//RatingBar是否是一个指示器（用户无法进行更改）

    var foregroundRatingView: UIView!
    var backgroundRatingView: UIView!
    
    var delegate: RatingBarDelegate?
    var isDraw = false
    
    func buildView(){
        if isDraw {return}
        isDraw = true
        //创建前后两个View，作用是通过rating数值显示或者隐藏“foregroundRatingView”来改变RatingBar的星星效果
        self.backgroundRatingView = self.createRatingView(imageName: "rating")
        self.foregroundRatingView = self.createRatingView(imageName: "rating_green")
        
        animationRatingChange()
        self.addSubview(self.backgroundRatingView)
        self.addSubview(self.foregroundRatingView)
        //加入单击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RatingBar.tapRateView(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        buildView()
        let animationTimeInterval = self.canAnimation ? self.animationTimeInterval : 0
        //开启动画改变foregroundRatingView可见范围
        UIView.animate(withDuration: animationTimeInterval, animations: {self.animationRatingChange()})
    }
    //改变foregroundRatingView可见范围
    func animationRatingChange(){
        let realRatingScore = self.rating / self.ratingMax
        self.foregroundRatingView.frame = CGRect(x: 0, y: 0,width: self.bounds.size.width * realRatingScore, height: self.bounds.size.height)

    }
    //根据图片名，创建一列RatingView
    func createRatingView(imageName: String) -> UIView{
        let view = UIView(frame: self.bounds)
        view.clipsToBounds = true
        view.backgroundColor = UIColor.clear
        //开始创建子Item,根据numStars总数
        for position in 0 ..< numStars{
            
            let img = UIImage(named: imageName)!
            let imageView = UIImageView.init(image: img)

            let width = (self.bounds.size.width - CGFloat((numStars - 1) * 2)) / CGFloat(numStars)
            
            imageView.frame = CGRect(x: CGFloat(position) * width +  CGFloat(position) * 2, y: 0, width: width, height: self.bounds.size.height)
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            view.addSubview(imageView)
        }
        return view
    }
    //点击编辑分数后，通过手势的x坐标来设置数值
    @objc func tapRateView(_ sender: UITapGestureRecognizer){
        if isIndicator {return}//如果是指示器，就不能交互
        let tapPoint = sender.location(in: self)
        let offset = tapPoint.x
        //通过x坐标判断分数
        let realRatingScore = offset / (self.bounds.size.width / ratingMax);
        self.rating = self.incomplete ? realRatingScore : round(realRatingScore)

    }
}
protocol RatingBarDelegate{
    func ratingDidChange(_ ratingBar: RatingBar,rating: CGFloat)
}
