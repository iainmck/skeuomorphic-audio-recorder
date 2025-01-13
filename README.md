# Skeuomorphic / Realistic Audio Device

This is a SwiftUI implementation of a realistic-looking device with metal, rubber, and glass components. 
Intended for use in iOS apps. The buttons, display, microphone are all functional.

<img src="demo2.PNG" alt="demo image" width="400"/>

Based on Jon Kantner's [original design](https://codepen.io/jkantner/pen/VwoaqoG) for web.

## Testing

Open in XCode and run the iOS previewer. No packages required.

Development note: There is a difference in how the iOS previewer on Mac and the actual device render shadows. This code has been optimized for presentation on an actual device. Make sure you live preview on a real device in the final stages, otherwise your fine-tuning of shadows will be wasted.

Production note: I don't recommend copy-pasting into production as every shadow is rendered and the main thread absolutely takes a performance hit. It makes much more sense to use an image for anything static (eg the bulk of this device) and only use shadows where you need dynamic control.

## More by me

Check out [iain.website](https://iain.website).

## Contributing

Pull requests are welcome.

## License

[MIT](/LICENSE.txt)
