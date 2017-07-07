//
//  TH_iOSWrapper.h
//  mh-iphone
//
//  Created by Everest Team on 5/25/17.
//
//

#ifndef TH_iOSWrapper_h
#define TH_iOSWrapper_h


// TheInputImage and theOutputImage need to point to UIImages with valid bitmap data;
// theOutputImage should be created by the caller with the same bitmap format and size as the input bitmap
//BOOL EverestRunMainTH(UIImage *theInputImage, UIImage *theOutputImage);
BOOL EverestRunMainTH(UIImage *theInputUIImage, unsigned char *theOutputImageBits);


#endif /* TH_iOSWrapper_h */
