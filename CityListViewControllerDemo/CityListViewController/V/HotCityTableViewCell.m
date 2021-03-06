//
//  HotCityTableViewCell.m
//  CityListViewController
//
//  Created by NengQuan on 16/8/23.
//  Copyright © 2016年 NengQuan. All rights reserved.
//

#import "HotCityTableViewCell.h"
#import "MYHotCityCollectionReusableView.h"
#import "MYHotCityCollectionViewCell.h"
#import "MYCityEntyM.h"
#import "MYCityListManager.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width

@interface HotCityTableViewCell () <UICollectionViewDataSource , UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic,strong) NSMutableArray<MYCityEntyM *> *cityArray; // 城市数组
@property (nonatomic,strong) NSMutableArray<NSData *> *historyArray; // 历史数据数组

@end
@implementation HotCityTableViewCell
static NSString * const MYHotCityCollectionViewCellID = @"MYHotCityCollectionViewCellID";
static NSString * const MYHotCityCollectionReusableViewID = @"MYHotCityCollectionReusableViewID";

- (void)awakeFromNib {
    // Initialization code
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.collectionViewLayout = [self flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([MYHotCityCollectionViewCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:MYHotCityCollectionViewCellID];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([MYHotCityCollectionReusableView class]) bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:MYHotCityCollectionReusableViewID];
    
    self.cityArray = [[NSMutableArray alloc]initWithCapacity:0];
    self.historyArray = [[NSMutableArray alloc] initWithCapacity:4];
    // 更新历史数据
    [self updateHistoryArray];

}
/**
 *  更新历史数据
 */
- (void)updateHistoryArray
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSMutableArray *cityArray = [[NSMutableArray alloc] init];
    NSArray *array =[[NSUserDefaults standardUserDefaults] objectForKey:MYHistoryKey];
    
    if (array.count > 0) {
        for (NSData *data in array) {
            MYCityEntyM *cityM = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [cityArray addObject:cityM];
        }
        
        [dataArray addObjectsFromArray:array];
        
        for (int i = 0;i < (dataArray.count > 8 ?8 :dataArray.count);i++) {
            NSData *data = [dataArray objectAtIndex:i];
            [self.historyArray addObject:data];
        }
        
        [self.collectionView reloadData];
    }
    
}

static CGFloat sessionHeight = 54;
static CGFloat leftSpace = 8;
- (UICollectionViewFlowLayout *)flowLayout
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemW = 70;
    CGFloat itemH = 25;
    flowLayout.itemSize = CGSizeMake(itemW, itemH);
    NSInteger minimumInteritemSpacing = (ScreenWidth - 4 * itemW )/ 5;
    flowLayout.minimumLineSpacing = 15;
    if (ScreenWidth > 320) {
        flowLayout.minimumInteritemSpacing = minimumInteritemSpacing;
    } else {
        flowLayout.minimumInteritemSpacing = 0 ; 
    }
    flowLayout.headerReferenceSize = CGSizeMake(ScreenWidth, sessionHeight);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    return flowLayout;
}
/**
 *  重写城市数据set方法
 *
 */
- (void)setData:(NSArray *)array
{
    self.cityArray = [array copy];
    [self.collectionView reloadData];
}

#pragma mark - collectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0 ) { // 历史
        if(self.historyArray.count == 0) {
            return  0;
        } else {
            return self.historyArray.count;
        }
    } else if (section == 1 && self.cityArray.count != 0) { // 热门
        return self.cityArray.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
     MYHotCityCollectionViewCell *cityCell = [collectionView dequeueReusableCellWithReuseIdentifier:MYHotCityCollectionViewCellID forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        NSData *data = [self.historyArray objectAtIndex:indexPath.row];
        MYCityEntyM *cityM = [NSKeyedUnarchiver unarchiveObjectWithData:data];
         cityCell.cityLabel.text = cityM.cityName;
    } else if (indexPath.section == 1) {
        MYCityEntyM *cityM = [self.cityArray objectAtIndex:indexPath.row];
        cityCell.cityLabel.text = cityM.cityName;
    }
    
    [cityCell.cityLabel.layer setBorderWidth:1];
    [cityCell.cityLabel.layer setBorderColor:[MYCityListManager collectionViewCellColor].CGColor];
    [cityCell.cityLabel.layer setCornerRadius:4];
    [cityCell.cityLabel.layer setMasksToBounds:YES];
    
    return cityCell;
}
// 设置collectionviewsessionheader
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        MYHotCityCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:MYHotCityCollectionReusableViewID forIndexPath:indexPath ];
        if (indexPath.section == 0) {
            if (self.historyArray.count == 0) {
            } else {
                headerView.headerLabel.text = @"搜索历史";
            }
        } else if (indexPath.section == 1) {
            headerView.headerLabel.text = @"热门城市";
        }
        return headerView;
    }
    return [UICollectionReusableView alloc];
}
/**
 *  设置collectionviewsessionheader的高度
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize size = CGSizeMake(0, 0);
    if (section == 0 && self.historyArray.count == 0) {
        return size;
    } else if (section == 1 && self.cityArray.count == 0) {
        return size;
    }
    return CGSizeMake(ScreenWidth, sessionHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MYCityEntyM *cityM = nil;
    if (indexPath.section == 0) {
        NSData *data = [self.historyArray objectAtIndex:indexPath.row];
        cityM = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [[NSUserDefaults standardUserDefaults] setValue:cityM.cityName forKey:MYSelectCityKey];
        
        for (NSData *data in self.historyArray) {
            MYCityEntyM *city = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if ([city.cityCode isEqualToString:cityM.cityCode]) {
                [self.historyArray removeObject:data];
                break;
            }
        }
        [self.historyArray insertObject:data atIndex:0];
        [self saveToPlist:self.historyArray];
        
        if ([self.hotcityDelegate respondsToSelector:@selector(historyCityCellDidSelectCity:)]) {
            [self.hotcityDelegate historyCityCellDidSelectCity:cityM.cityName];
        }
        [self.viewController.navigationController popViewControllerAnimated:YES];
        
    } else if (indexPath.section == 1) {
        
        cityM = [self.cityArray objectAtIndex:indexPath.row];
        
        [[NSUserDefaults standardUserDefaults] setValue:cityM.cityName forKey:MYSelectCityKey];
        
        for (NSData *data in self.historyArray) {
            MYCityEntyM *city = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if ([city.cityCode isEqualToString:cityM.cityCode]) {
                [self.historyArray removeObject:data];
                break;
            }
        }
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cityM];
        [self.historyArray insertObject:data atIndex:0];
        [self saveToPlist:self.historyArray];
        
        if ([self.hotcityDelegate respondsToSelector:@selector(hotCityCellDidSelectCity:)]) {
            [self.hotcityDelegate hotCityCellDidSelectCity:cityM.cityName];
        }
        
        [self.viewController.navigationController popViewControllerAnimated:YES];
    }
}

- (void)saveToPlist:(NSMutableArray *)array
{
    NSArray *dataArray = [NSArray arrayWithArray:array];
    [[NSUserDefaults standardUserDefaults] setValue:dataArray forKey:MYHistoryKey];
     [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - collectionViewLayoutDelegate
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, leftSpace, 0, leftSpace);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
