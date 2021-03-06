//
//  Graphic.m
//  GridEngine
//
//  Created by Liy on 10-2-18.
//  Copyright 2010 Bangboo. All rights reserved.
//

#import "GESprite.h"
#import "GESpriteBatch.h"

@implementation GESprite

- (BOOL)draw{
	//decide whether to process draw function
	if ([super draw]) {
		if (immediateMode) {
			[[GESpriteBatch sharedSpriteBatch] batchNode:self];
			return YES;
		}
		
		//save the current matrix
		glPushMatrix();
		
		//enable to use coords array as a source texture
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glEnableClientState(GL_COLOR_ARRAY);
		
		//enable texture 2d
		glEnable(GL_TEXTURE_2D);
		
		//bind the texture.
		//The texture we are using here is loaded using Texture2D, which is texture size always be n^2.
		if (texManager.boundedTex != [texRef name]) {
			glBindTexture(GL_TEXTURE_2D, [texRef name]);
			texManager.boundedTex = [texRef name];
		}
		else {
			//NSLog(@"Image already binded");
		}
		
		//get the start memory address for the tvcQuad struct.
		//Note that tvcQuad is defined as array, we need to access the actual tvcQuad memory address using normal square bracket.
		int addr = (int)&tvcQuads[0];
		//int addr = (int)&tvcQuad;
		//calculate the memory location offset, should be 0. Since there is nothing before texCoords property of TVCQuad.
		int offset = offsetof(TVCPoint, texCoords);
		//set the texture coordinates we what to render from. (positions on the Texture2D generated image)
		glTexCoordPointer(2, GL_FLOAT, sizeof(TVCPoint), (void*) (addr));
		
		//memory offset to define the start of vertices. Should be sizeof(texCoords) which is 8 bytes(2 GLfloat each for 4 bytes).
		offset = offsetof(TVCPoint, vertices);
		//set the target vertices which define the area we what to draw the texture.
		glVertexPointer(2, GL_FLOAT, sizeof(TVCPoint), (void*) (addr + offset));
		
		//offset to define the start of color array. Before this property we have texCoords(u & v GLfloat) 
		//and vertices(x & y GLfloat) which are 16 bytes.
		offset = offsetof(TVCPoint, color);
		//set the color tint array for the texture.
		glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(TVCPoint), (void*)(addr + offset));
		
		//enable blend
		glEnable(GL_BLEND);
		
		glBlendFunc(blendFunc.src, blendFunc.dst);
		
		//draw the image
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		
		//reset to default blend function
		glBlendFunc(DEFAULT_BLEND_SRC, DEFAULT_BLEND_DST);
		
		//disable
		glDisable(GL_BLEND);
		glDisable(GL_TEXTURE_2D);
		glDisableClientState(GL_COLOR_ARRAY);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		
		glPopMatrix();
		
		return YES;
	}
	return NO;
}



@end
