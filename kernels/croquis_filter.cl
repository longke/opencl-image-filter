/* Please Write the OpenCL Kernel(s) code here*/

__kernel void croquis_filter(__read_only image2d_t input,
                              __write_only image2d_t output){
   
   const sampler_t sampler = CLK_FILTER_NEAREST |
                             CLK_NORMALIZED_COORDS_FALSE |
                             CLK_ADDRESS_CLAMP_TO_EDGE;

   const int2 size = get_image_dim(input);

   float2 coord = (float2)(get_global_id(0),get_global_id(1));
   
   float4 color = read_imagef(input,sampler,coord);
   
   float arg = 1.0f;
  
   float dx = 1.0f / size.x;
   float dy = 1.0f / size.y;
   float c  = -1.0f / 8.0f;
   
    
   float r = ((read_imagef(input,sampler, coord + (float2)(-dx, -dy)).x
          +    read_imagef(input,sampler, coord + (float2)(0.0, -dy)).x
          +    read_imagef(input,sampler, coord + (float2)( dx, -dy)).x
          +    read_imagef(input,sampler, coord + (float2)(-dx, 0.0)).x
          +    read_imagef(input,sampler, coord + (float2)( dx, 0.0)).x
          +    read_imagef(input,sampler, coord + (float2)(-dx,  dy)).x
          +    read_imagef(input,sampler, coord + (float2)(0.0,  dy)).x
          +    read_imagef(input,sampler, coord + (float2)( dx,  dy)).x) * c
          +    read_imagef(input,sampler, coord).x) * -2.0f; 
   
    float g = ((read_imagef(input,sampler, coord + (float2)(-dx, -dy)).y
          +   read_imagef(input,sampler, coord+ (float2)(0.0, -dy)).y
          +   read_imagef(input,sampler, coord + (float2)( dx, -dy)).y
          +   read_imagef(input,sampler, coord + (float2)(-dx, 0.0)).y
          +   read_imagef(input,sampler, coord + (float2)( dx, 0.0)).y
          +   read_imagef(input,sampler, coord + (float2)(-dx,  dy)).y
          +   read_imagef(input,sampler, coord + (float2)(0.0,  dy)).y
          +   read_imagef(input,sampler, coord + (float2)( dx,  dy)).y) * c
          +   read_imagef(input,sampler, coord).y) * -24.0;
          
    float b = ((read_imagef(input,sampler, coord + (float2)(-dx, -dy)).z
          +   read_imagef(input,sampler, coord + (float2)(0.0, -dy)).z
          +   read_imagef(input,sampler, coord + (float2)( dx, -dy)).z
          +   read_imagef(input,sampler, coord + (float2)(-dx, 0.0)).z
          +   read_imagef(input,sampler, coord + (float2)( dx, 0.0)).z
          +   read_imagef(input,sampler, coord + (float2)(-dx,  dy)).z
          +   read_imagef(input,sampler, coord + (float2)(0.0,  dy)).z
          +   read_imagef(input,sampler, coord + (float2)( dx,  dy)).z) * c
          +   read_imagef(input,sampler, coord).z) * -24.0;
          
   float brightness = (r * 0.3f + g * 0.59f + b * 0.11f);
   brightness = 1.0f - brightness;
   if (brightness < 0.0f) brightness = 0.0f;
   if (brightness > 1.0f) brightness = 1.0f;
   r = g = b = brightness;  
   
   float3 rgb = (float3)(r, g, b);
   float4 dst_color = (float4)(rgb - (1.0f - arg),1.0f);
   
   write_imagef(output,convert_int2(coord),dst_color);
 
}