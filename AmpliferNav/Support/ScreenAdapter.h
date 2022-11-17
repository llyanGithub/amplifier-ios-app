//
//  ScreenAdapter.h
//  AmpliferNav
//
//  Created by 鄢陵龙 on 2022/11/17.
//

#ifndef ScreenAdapter_h
#define ScreenAdapter_h

#define SWReadValue(value) ((value)/414.0f*[UIScreen mainScreen].bounds.size.width)
#define SHReadValue(value) ((value)/736.0f*[UIScreen mainScreen].bounds.size.height)


#endif /* ScreenAdapter_h */
