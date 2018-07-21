//
//  YBPopupMenu.m
//  YBPopupMenu
//
//  Created by LYB on 16/11/8.
//  Copyright © 2016年 LYB. All rights reserved.
//

#import "YBPopupMenu.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kMainWindow  [UIApplication sharedApplication].keyWindow

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kLineColor  [UIColorFromRGB(0x999999) colorWithAlphaComponent:0.62]

/**标准屏宽度*/
#define iPhoneStdWidth 375.f
#define iPhoneStdScaling (kScreenWidth/iPhoneStdWidth)

NS_INLINE
CGFloat
_iPhoneLayoutScaling_()
{
    if (kScreenWidth < iPhoneStdWidth)
        return iPhoneStdScaling;
    else
        return 1.0f;
}
#define iPhoneLayoutScaling (_iPhoneLayoutScaling_())
NS_INLINE
CGFloat
_tcm_layout_(CGFloat layout, CGFloat scale)
{
    return layout*scale;
}
#define TCM_Layout(layout)                      (_tcm_layout_((layout),iPhoneLayoutScaling))

#pragma mark - /////////////////
#pragma mark - private categorys

@interface UIView (YBFrame)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGPoint origin;

@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize  size;

@end


@implementation UIView (YBFrame)

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)value
{
    CGRect frame = self.frame;
    frame.origin.x = value;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)value
{
    CGRect frame = self.frame;
    frame.origin.y = value;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

@end


#pragma mark - /////////////
#pragma mark - private cell

@interface YBPopupMenuCell : UITableViewCell
@property (nonatomic, assign) BOOL isShowSeparator;
@property (nonatomic, strong) UIColor * ad_separatorColor;
@end

@implementation YBPopupMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _isShowSeparator = YES;
        self.backgroundColor = [UIColor clearColor];
        [self setNeedsDisplay];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (!_isShowSeparator) return;
    CALayer *line = [CALayer layer];
    line.frame = CGRectMake(0, rect.size.height - 0.5, rect.size.width, 0.5);
    line.backgroundColor = _ad_separatorColor.CGColor;
    [self.layer addSublayer:line];
}

@end


#pragma mark - ///////////
#pragma mark - YBPopupMenu

@interface YBPopupMenu ()
<
UITableViewDelegate,
UITableViewDataSource
>
@end

@implementation YBPopupMenu
{
    
    UIView * _mainView;
    UITableView * _contentView;
    UIView * _bgView;
    
    CGPoint _anchorPoint;
    
    CGFloat kArrowHeight;
    CGFloat kArrowWidth;
    CGFloat kArrowPosition;
    CGFloat kButtonHeight;
    
    NSArray * _titles;
    NSArray * _icons;
    NSArray * _badges;
    
    UIColor * _contentColor;
    UIColor * _separatorColor;
}

@synthesize cornerRadius = kCornerRadius;

- (instancetype)initWithTitles:(NSArray *)titles
                         icons:(NSArray *)icons
                        badges:(NSArray *)badges
                     menuWidth:(CGFloat)itemWidth
                      delegate:(id<YBPopupMenuDelegate>)delegate
{
    if (self = [super init]) {
        
        kArrowHeight = 10;
        kArrowWidth = 15;
        kButtonHeight = TCM_Layout(53);
        kCornerRadius = 3.0;
        _titles = titles;
        _icons  = icons;
        _badges = badges;
        _dismissOnSelected = YES;
        _fontSize = 15.0;
        _textColor = UIColorFromRGB(0xE0E0E0);
        _offset = 0.0;
        _type = YBPopupMenuTypeDefault;
        _contentColor = [UIColor whiteColor];
        _separatorColor = kLineColor;
        
        if (delegate) self.delegate = delegate;
        
        self.width = itemWidth;
        self.height = (titles.count > 5 ? 5 * kButtonHeight : titles.count * kButtonHeight) + 2 * kArrowHeight;
        
        kArrowPosition = 0.5 * self.width - 0.5 * kArrowWidth;
        
        self.alpha = 0;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 2.0;
        
        _mainView = [[UIView alloc] initWithFrame: self.bounds];
        _mainView.backgroundColor = _contentColor;
        _mainView.layer.cornerRadius = kCornerRadius;
        _mainView.layer.masksToBounds = YES;
        
        _contentView = [[UITableView alloc] initWithFrame: _mainView.bounds style:UITableViewStylePlain];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.delegate = self;
        _contentView.dataSource= self;
        _contentView.bounces = titles.count > 5;
        _contentView.tableFooterView = [UIView new];
        _contentView.separatorStyle = 0;
        _contentView.rowHeight = kButtonHeight;
        _contentView.height -= 2 * kArrowHeight;
        _contentView.centerY = _mainView.centerY;
        
   
        
        [_mainView addSubview: _contentView];
        [self addSubview: _mainView];
        
        _bgView = [[UIView alloc] initWithFrame: [UIScreen mainScreen].bounds];
        _bgView.backgroundColor = nil;
        _bgView.alpha = 0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(dismiss)];
        [_bgView addGestureRecognizer: tap];
    }
    return self;
}

- (void)show {
    
    [kMainWindow addSubview: _bgView];
    [kMainWindow addSubview: self];
    YBPopupMenuCell *cell = [self getLastVisibleCell];
    cell.isShowSeparator = NO;
    self.layer.affineTransform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration: 0.25 animations:^{
        self.layer.affineTransform = CGAffineTransformMakeScale(1.0, 1.0);
        self.alpha = 1;
        self->_bgView.alpha = 1;
    }];
}

- (void)dismiss
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ybPopupMenuBeganDismiss)]) {
        [self.delegate ybPopupMenuBeganDismiss];
    }
    [UIView animateWithDuration: 0.25 animations:^{
        self.layer.affineTransform = CGAffineTransformMakeScale(0.1, 0.1);
        self.alpha = 0;
        self->_bgView.alpha = 0;
    } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ybPopupMenuDidDismiss)]) {
            [self.delegate ybPopupMenuDidDismiss];
        }
        self.delegate = nil;
        [self removeFromSuperview];
        [self->_bgView removeFromSuperview];
    }];
}

- (void)showAtPoint:(CGPoint)point
{
    _mainView.layer.mask = [self getMaskLayerWithPoint:point];

    [self show];
}

- (void)showRelyOnView:(UIView *)view
{
    CGRect absoluteRect = [view convertRect:view.bounds toView:kMainWindow];
    CGPoint relyPoint = CGPointMake(CGRectGetMidX(absoluteRect),CGRectGetMaxY(absoluteRect));
    _mainView.layer.mask = [self getMaskLayerWithPoint:relyPoint];
    if (self.y < _anchorPoint.y) {
        self.y -= absoluteRect.size.height;
    }
    [self show];
}

+ (instancetype)showAtPoint:(CGPoint)point titles:(NSArray *)titles icons:(NSArray *)icons badges:(NSArray *)badges menuWidth:(CGFloat)itemWidth delegate:(id<YBPopupMenuDelegate>)delegate
{
    YBPopupMenu *popupMenu = [[YBPopupMenu alloc] initWithTitles:titles icons:icons       badges:badges menuWidth:itemWidth delegate:delegate];
    [popupMenu showAtPoint:point];
    return popupMenu;
}

+ (instancetype)showRelyOnView:(UIView *)view titles:(NSArray *)titles icons:(NSArray *)icons badges:(NSArray *)badges menuWidth:(CGFloat)itemWidth delegate:(id<YBPopupMenuDelegate>)delegate
{
    YBPopupMenu *popupMenu = [[YBPopupMenu alloc] initWithTitles:titles icons:icons badges:badges menuWidth:itemWidth delegate:delegate];
    [popupMenu showRelyOnView:view];
    return popupMenu;
}

#pragma mark tableViewDelegate & dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"ybPopupMenu";
    YBPopupMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[YBPopupMenuCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.selectionStyle = 0;
    }
    
    cell.textLabel.textColor = _textColor;
    cell.textLabel.font = [UIFont systemFontOfSize:_fontSize];
    cell.textLabel.text = _titles[indexPath.row];
    cell.ad_separatorColor = _separatorColor;
    
    if (_icons.count >= indexPath.row + 1) {
        if ([_icons[indexPath.row] isKindOfClass:[NSString class]]) {
            cell.imageView.image = [UIImage imageNamed:_icons[indexPath.row]];
        }else if ([_icons[indexPath.row] isKindOfClass:[UIImage class]]){
            cell.imageView.image = _icons[indexPath.row];
        }else {
            cell.imageView.image = nil;
        }
    }else {
        cell.imageView.image = nil;
    }
    
    if (_badges.count) {
        NSInteger badgeI = [_badges[indexPath.row] integerValue];
        if (badgeI < 1) {
            cell.accessoryView = nil;
        } else {
            NSString *badge = [_badges[indexPath.row] stringValue];
            CGFloat ext = 0;
            if (badgeI > 99) {
                badge = @"99+";
                ext = 10;
            }
            
            UILabel *badgeL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20+ext, 20)];
            
            badgeL.layer.masksToBounds = YES;
            badgeL.layer.cornerRadius = 10.;
            badgeL.font = [UIFont systemFontOfSize:12];
            badgeL.textAlignment = NSTextAlignmentCenter;
            badgeL.adjustsFontSizeToFitWidth = YES;
            badgeL.backgroundColor =  UIColorFromRGB(0xFF0033);
            badgeL.textColor = [UIColor whiteColor];
            cell.accessoryView = badgeL;
            
            badgeL.text = badge;
        }
    }
    return cell;
}

- (void)updateIcon:(NSString *)icon forIndex:(NSUInteger)index
{
    NSMutableArray *temp = [NSMutableArray arrayWithArray:_icons];
    [temp replaceObjectAtIndex:index withObject:icon];
    _icons = temp.copy;
    
    [_contentView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_dismissOnSelected) [self dismiss];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(ybPopupMenuDidSelectedAtIndex:ybPopupMenu:)]) {
        
        [self.delegate ybPopupMenuDidSelectedAtIndex:indexPath.row ybPopupMenu:self];
    }
}

#pragma mark - scrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    YBPopupMenuCell *cell = [self getLastVisibleCell];
    cell.isShowSeparator = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    YBPopupMenuCell *cell = [self getLastVisibleCell];
    cell.isShowSeparator = NO;
}

- (YBPopupMenuCell *)getLastVisibleCell
{
    NSArray <NSIndexPath *>*indexPaths = [_contentView indexPathsForVisibleRows];
    indexPaths = [indexPaths sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *  _Nonnull obj1, NSIndexPath *  _Nonnull obj2) {
        return obj1.row < obj2.row;
    }];
    NSIndexPath *indexPath = indexPaths.firstObject;
    return [_contentView cellForRowAtIndexPath:indexPath];
}

#pragma mark private functions
- (void)setType:(YBPopupMenuType)type
{
    _type = type;
    switch (type) {
        case YBPopupMenuTypeDark:
        {
            _textColor =  UIColorFromRGB(0xE0E0E0);
            _contentColor = [UIColorFromRGB(0x3d4145) colorWithAlphaComponent:0.95];
            _separatorColor = kLineColor;
        }
            break;
            
        default:
        {
            _textColor = [UIColor blackColor];
            _contentColor = [UIColor whiteColor];
            _separatorColor = [UIColor lightGrayColor];
        }
            break;
    }
    _mainView.backgroundColor = _contentColor;
    [_contentView reloadData];
}

- (void)setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
    [_contentView reloadData];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [_contentView reloadData];
}

- (void)setDismissOnTouchOutside:(BOOL)dismissOnTouchOutside
{
    _dismissOnSelected = dismissOnTouchOutside;
    if (!dismissOnTouchOutside) {
        for (UIGestureRecognizer *gr in _bgView.gestureRecognizers) {
            [_bgView removeGestureRecognizer:gr];
        }
    }
}

- (void)setIsShowShadow:(BOOL)isShowShadow
{
    _isShowShadow = isShowShadow;
    if (!isShowShadow) {
        self.layer.shadowOpacity = 0.0;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 0.0;
    }
}

- (void)setOffset:(CGFloat)offset
{
    _offset = offset;
    if (offset < 0) {
        offset = 0.0;
    }
    self.y += self.y >= _anchorPoint.y ? offset : -offset;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    kCornerRadius = cornerRadius;
    _mainView.layer.mask = [self drawMaskLayer];
    if (self.y < _anchorPoint.y) {
        _mainView.layer.mask.affineTransform = CGAffineTransformMakeRotation(M_PI);
    }
}

- (void)setAnimationAnchorPoint:(CGPoint)point
{
    CGRect originRect = self.frame;
    self.layer.anchorPoint = point;
    self.frame = originRect;
}

- (void)determineAnchorPoint
{
    CGPoint aPoint = CGPointMake(0.5, 0.5);
    if (CGRectGetMaxY(self.frame) > kScreenHeight) {
        aPoint = CGPointMake(fabs(kArrowPosition+kArrowWidth*0.5) / self.width, 1);
    }else {
        aPoint = CGPointMake(fabs(kArrowPosition+kArrowWidth*0.5) / self.width, 0);
    }
    [self setAnimationAnchorPoint:aPoint];
}

- (CAShapeLayer *)getMaskLayerWithPoint:(CGPoint)point
{
    [self setArrowPointingWhere:point];
    CAShapeLayer *layer = [self drawMaskLayer];
    [self determineAnchorPoint];
    if (CGRectGetMaxY(self.frame) > kScreenHeight) {
        
        kArrowPosition = self.width - kArrowPosition - kArrowWidth;
        layer = [self drawMaskLayer];
        layer.affineTransform = CGAffineTransformMakeRotation(M_PI);
        self.y = _anchorPoint.y - self.height;
    }
    self.y += self.y >= _anchorPoint.y ? _offset : -_offset;
    return layer;
}

- (void)setArrowPointingWhere: (CGPoint)anchorPoint
{
    _anchorPoint = anchorPoint;
    
    self.x = anchorPoint.x - kArrowPosition;
    self.y = anchorPoint.y;
    
    CGFloat maxX = CGRectGetMaxX(self.frame);
    CGFloat minX = CGRectGetMinX(self.frame);
    
    if (maxX > kScreenWidth - 10) {
        self.x = kScreenWidth - 10 - self.width;
    }else if (minX < 10) {
        self.x = 10;
    }
    
    maxX = CGRectGetMaxX(self.frame);
    minX = CGRectGetMinX(self.frame);
    
    if ((anchorPoint.x <= maxX - kCornerRadius) && (anchorPoint.x >= minX + kCornerRadius)) {
        kArrowPosition = anchorPoint.x - minX - 0.5*kArrowWidth;
    }else if (anchorPoint.x < minX + kCornerRadius) {
        kArrowPosition = kCornerRadius;
    }else {
        kArrowPosition = self.width - kCornerRadius - kArrowWidth;
    }
}

- (CAShapeLayer *)drawMaskLayer
{
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = _mainView.bounds;

    CGPoint topRightArcCenter = CGPointMake(self.width-kCornerRadius, kArrowHeight+kCornerRadius);
    CGPoint topLeftArcCenter = CGPointMake(kCornerRadius, kArrowHeight+kCornerRadius);
    CGPoint bottomRightArcCenter = CGPointMake(self.width-kCornerRadius, self.height - kArrowHeight - kCornerRadius);
    CGPoint bottomLeftArcCenter = CGPointMake(kCornerRadius, self.height - kArrowHeight - kCornerRadius);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint: CGPointMake(0, kArrowHeight+kCornerRadius)];
    [path addLineToPoint: CGPointMake(0, bottomLeftArcCenter.y)];
    [path addArcWithCenter: bottomLeftArcCenter radius: kCornerRadius startAngle: M_PI endAngle: M_PI_2 clockwise: NO];
    [path addLineToPoint: CGPointMake(self.width-kCornerRadius, self.height - kArrowHeight)];
    [path addArcWithCenter: bottomRightArcCenter radius: kCornerRadius startAngle: -M_PI-M_PI_2 endAngle: -M_PI*2 clockwise: NO];
    [path addLineToPoint: CGPointMake(self.width, kArrowHeight+kCornerRadius)];
    [path addArcWithCenter: topRightArcCenter radius: kCornerRadius startAngle: 0 endAngle: -M_PI_2 clockwise: NO];
    
    [path addLineToPoint: CGPointMake(kArrowPosition+kArrowWidth, kArrowHeight)];
    [path addLineToPoint: CGPointMake(kArrowPosition+0.5*kArrowWidth+3, 3)];
    
//    [path addArcWithCenter:CGPointMake(kArrowPosition + kArrowWidth*0.5, 5) radius:3. startAngle:0 endAngle:M_PI clockwise:NO];
    
    [path addQuadCurveToPoint:CGPointMake(kArrowPosition+0.5*kArrowWidth-3, 3) controlPoint:CGPointMake(kArrowPosition + kArrowWidth*0.5, -3)];
    
    [path addLineToPoint: CGPointMake(kArrowPosition, kArrowHeight)];
    [path addLineToPoint: CGPointMake(kCornerRadius, kArrowHeight)];
    [path addArcWithCenter: topLeftArcCenter radius: kCornerRadius startAngle: -M_PI_2 endAngle: -M_PI clockwise: NO];
    [path closePath];
    
    maskLayer.path = path.CGPath;
    
    return maskLayer;
}

@end